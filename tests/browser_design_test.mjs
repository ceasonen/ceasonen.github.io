// Optional visual QA: node tests/browser_design_test.mjs [URL] [CDP port].
// Uses an isolated Chrome instance and the public build, never manuscript files.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';

const [url = 'http://127.0.0.1:4000/', port = '9225'] = process.argv.slice(2);
const tabs = await (await fetch(`http://127.0.0.1:${port}/json`)).json();
const ws = new WebSocket(tabs.find(tab => tab.type === 'page').webSocketDebuggerUrl);
await new Promise(resolve => ws.addEventListener('open', resolve, {once: true}));
let id = 0;
const pending = new Map();
ws.addEventListener('message', event => {
  const result = JSON.parse(event.data);
  if (result.id) {
    pending.get(result.id)?.(result);
    pending.delete(result.id);
  }
});
const send = (method, params = {}) => new Promise((resolve, reject) => {
  const requestId = ++id;
  pending.set(requestId, result => result.error ? reject(result.error) : resolve(result.result));
  ws.send(JSON.stringify({id: requestId, method, params}));
});
const evaluate = async expression => {
  const result = await send('Runtime.evaluate', {expression, returnByValue: true, awaitPromise: true});
  if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
  return result.result.value;
};
const waitFor = expression => evaluate(`new Promise((resolve,reject) => {
  const started = performance.now();
  const tick = () => {
    if (${expression}) return resolve(true);
    if (performance.now() - started > 6000) return reject(new Error('Timed out: '+${JSON.stringify(expression)}));
    setTimeout(tick, 60);
  }; tick();
})`);
const screenshot = async label => fs.writeFile(`.build/preview/refined-${label}.png`, Buffer.from((await send('Page.captureScreenshot')).data, 'base64'));
const navigate = async section => {
  await evaluate(`document.querySelector('.section-nav a[href="/#${section}"]').click()`);
  await waitFor(`location.hash === '#${section}' && document.querySelector('.section-nav a[aria-current]')?.getAttribute('href') === '/#${section}' && (Math.abs(document.querySelector('#${section}').getBoundingClientRect().top - (document.querySelector('.site-header').getBoundingClientRect().bottom + 24)) < 4 || Math.ceil(scrollY + innerHeight) >= document.documentElement.scrollHeight - 3)`);
  await evaluate(`new Promise(resolve => {
    let position = scrollY, stableSince = performance.now();
    const tick = () => {
      if (Math.abs(scrollY - position) > .1) { position = scrollY; stableSince = performance.now(); }
      if (performance.now() - stableSince > 180) return resolve();
      setTimeout(tick, 60);
    }; tick();
  })`);
};

try {
  await send('Page.enable');
  await send('Emulation.setFocusEmulationEnabled', {enabled: true});
  await send('Emulation.setEmulatedMedia', {features: [{name: 'prefers-reduced-motion', value: 'reduce'}]});
  await send('Page.navigate', {url});
  await waitFor(`document.readyState === 'complete' && !!document.querySelector('#service')`);
  await evaluate('document.fonts.ready');
  assert.equal(await evaluate(`document.fonts.check('600 16px Nunito')`), true);
  await send('DOM.enable');
  await send('CSS.enable');
  const root = (await send('DOM.getDocument')).root.nodeId;
  for (const selector of ['h1', '.profile-status', '.news-list li > span', '.experience-info p', '.project-card h3 a', '.award-card h3', '.publication-summary', '.service-line']) {
    const nodeId = (await send('DOM.querySelector', {nodeId: root, selector})).nodeId;
    const fonts = (await send('CSS.getPlatformFontsForNode', {nodeId})).fonts;
    assert(fonts.some(font => font.isCustomFont && font.postScriptName.startsWith('Nunito')), selector);
    assert(fonts.every(font => font.isCustomFont || font.familyName.includes('Emoji')), `Unexpected fallback font: ${selector}`);
  }
  console.log('PASS: actual rendered Nunito font across all eight text surfaces');

  for (const width of [320,390,768,1024,1100,1280,1440,1920]) {
    await send('Emulation.setDeviceMetricsOverride', {width, height: 1000, deviceScaleFactor: 1, mobile: width < 600});
    const state = await evaluate(`({width: innerWidth, content: document.documentElement.scrollWidth})`);
    assert.equal(state.width, width);
    assert.equal(state.content, width, `Overflow at ${width}px`);
  }
  console.log('PASS: no horizontal overflow at eight viewport widths');

  await navigate('experience');
  await waitFor(`[...document.querySelectorAll('.education-icon img')].length === 2 && [...document.querySelectorAll('.education-icon img')].every(img => img.complete && img.naturalWidth > 0)`);
  const emblems = await evaluate(`[...document.querySelectorAll('.education-icon img')].map(img => ({width:img.getBoundingClientRect().width,height:img.getBoundingClientRect().height,fit:getComputedStyle(img).objectFit}))`);
  assert.equal(emblems[0].width, emblems[1].width);
  for (const emblem of emblems) {
    assert.equal(emblem.width, emblem.height);
    assert.equal(emblem.fit, 'contain');
  }
  assert.equal(await evaluate(`document.querySelectorAll('.research-interests').length`), 0);
  console.log('PASS: both education emblems load at matching square sizes, with no duplicate interest list');

  for (const [filter, count] of [['accepted',3], ['preprint',4], ['all',7]]) {
    await evaluate(`document.querySelector('[data-filter="${filter}"]').click()`);
    assert.equal(await evaluate(`document.querySelectorAll('.publication-card:not([hidden])').length`), count);
    assert.equal(await evaluate(`document.querySelector('.publication-count').textContent`), `${count} papers`);
  }
  console.log('PASS: one set of seven cards, all publication filters');

  for (const width of [1440,390]) {
    await send('Emulation.setDeviceMetricsOverride', {width, height: width === 390 ? 844 : 1100, deviceScaleFactor: 1, mobile: width === 390});
    for (const section of ['about','news','experience','projects','awards','publications','service']) {
      await navigate(section);
      await screenshot(`${width}-${section}`);
    }
  }
  assert.equal(await evaluate(`location.hash`), '#service');
  assert.equal(await evaluate(`document.querySelector('.section-nav a[aria-current]').textContent.trim()`), 'Service');
  console.log('PASS: every section and last-section navigation on desktop and mobile');

  await evaluate(`document.querySelector('.nav-toggle').click()`);
  assert.equal(await evaluate(`document.querySelector('.nav-toggle').getAttribute('aria-expanded')`), 'true');
  await send('Input.dispatchKeyEvent', {type:'keyDown',key:'Escape',code:'Escape',windowsVirtualKeyCode:27});
  assert.equal(await evaluate(`document.querySelector('.nav-toggle').getAttribute('aria-expanded')`), 'false');
  assert.equal(await evaluate(`getComputedStyle(document.querySelector('.welcome-wave')).animationName`), 'none');
  const links = await evaluate(`[...document.querySelectorAll('.publication-card .publication-links a')].map(a=>({label:a.textContent.trim(),url:a.href}))`);
  assert.equal(links.length, 5);
  assert.equal(links.filter(link => link.label === '[PDF]').length, 3);
  assert.equal(links.filter(link => link.label === '[Code]').length, 1);
  assert.equal(links.filter(link => link.label === '[Project]').length, 1);
  assert(links.every(link => !link.url.includes('/abs/') && !link.url.includes('researchgate')));
  const marks = await evaluate(`({legend:getComputedStyle(document.querySelector('.publication-legend')).fontSize, author:getComputedStyle(document.querySelector('.publication-authors')).fontSize, superscript:getComputedStyle(document.querySelector('.publication-authors sup')).fontSize})`);
  assert(parseFloat(marks.legend) >= 15);
  assert(parseFloat(marks.author) >= 14);
  assert(parseFloat(marks.superscript) >= 12);
  const pdf = await evaluate(`fetch('/assets/papers/deepyolo-ijcnn-2026.pdf').then(async r=>({ok:r.ok,type:r.headers.get('content-type'),signature:(await r.text()).slice(0,5)}))`);
  assert.equal(pdf.ok, true);
  assert(pdf.type.includes('application/pdf'));
  assert.equal(pdf.signature, '%PDF-');
  console.log('PASS: keyboard menu, reduced motion and direct IJCNN PDF response');
  await send('Emulation.setEmulatedMedia', {features: [{name: 'prefers-reduced-motion', value: 'no-preference'}]});
  for (const section of ['about','publications','service']) await navigate(section);
  console.log('PASS: normal-motion anchor navigation, including the last section');
} catch (error) {
  console.log('Failure layout', await evaluate(`({width:innerWidth,height:innerHeight,scroll:scrollY,page:document.documentElement.scrollHeight,hash:location.hash,service:document.querySelector('#service').getBoundingClientRect().top,active:document.querySelector('[aria-current]')?.textContent,visualHeight:visualViewport.height,scale:visualViewport.scale})`));
  await screenshot('failure');
  throw error;
} finally {
  ws.close();
}
