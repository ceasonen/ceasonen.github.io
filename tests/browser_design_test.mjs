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
  const {x, y} = await evaluate(`(() => {
    const link = document.querySelector('.section-nav a[href="/#${section}"]');
    if (link.getBoundingClientRect().bottom < 0) window.scrollTo({top: 0, behavior: 'instant'});
    const bounds = link.getBoundingClientRect();
    return {x: bounds.x + bounds.width / 2, y: bounds.y + bounds.height / 2};
  })()`);
  await send('Input.dispatchMouseEvent', {type: 'mousePressed', x, y, button: 'left', clickCount: 1});
  await send('Input.dispatchMouseEvent', {type: 'mouseReleased', x, y, button: 'left', clickCount: 1});
  await waitFor(`location.hash === '#${section}' && document.querySelector('.section-nav a[aria-current]')?.getAttribute('href') === '/#${section}' && document.querySelector('#${section}').getBoundingClientRect().top >= Math.max(0, document.querySelector('.site-header').getBoundingClientRect().bottom) - 1`);
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
  await send('DOM.enable');
  await send('CSS.enable');
  const root = (await send('DOM.getDocument')).root.nodeId;
  const textSurfaces = {
    h1: 'Caveat',
    '#about h2': 'Caveat',
    '#publications h2': 'Caveat',
    '.experience-internships > h3': 'Caveat',
    '.profile-introduction p': 'ComicNeue',
    '.intro-contact a': 'ComicNeue',
    '.section-nav a[href="/#about"]': 'Inter',
    '#writing h2': 'Caveat',
    '#writing .writing-empty': 'ComicNeue',
    '.section-nav .writing-nav-link': 'ComicNeue',
    '.profile-status': 'Inter',
    '.news-list li > span': 'Inter',
    '.experience-info p': 'Inter',
    '.project-name': 'Inter',
    '.award-name': 'Inter',
    '.publication-summary': 'Inter',
    '.service-list li': 'Inter',
  };
  for (const [selector, fontName] of Object.entries(textSurfaces)) {
    const nodeId = (await send('DOM.querySelector', {nodeId: root, selector})).nodeId;
    const fonts = (await send('CSS.getPlatformFontsForNode', {nodeId})).fonts;
    assert(fonts.some(font => font.isCustomFont && font.postScriptName.startsWith(fontName)), selector);
  }
  console.log('PASS: heading and body fonts render from local web fonts');

  for (const width of [320,390,768,1024,1025,1100,1280,1440,1920]) {
    await send('Emulation.setDeviceMetricsOverride', {width, height: 1000, deviceScaleFactor: 1, mobile: width < 600});
    const state = await evaluate(`(() => {
      const profile = document.querySelector('.profile-sidebar').getBoundingClientRect();
      const main = document.querySelector('main').getBoundingClientRect();
      return {
        width: innerWidth,
        content: document.documentElement.scrollWidth,
        leftColumn: profile.right < main.left,
        aboveContent: profile.bottom <= main.top,
      };
    })()`);
    assert.equal(state.width, width);
    assert.equal(state.content, width, `Overflow at ${width}px`);
    assert.equal(width > 760 ? state.leftColumn : state.aboveContent, true, `Profile layout at ${width}px`);
  }
  console.log('PASS: no horizontal overflow at nine viewport widths');

  await navigate('experience');
  await waitFor(`[...document.querySelectorAll('.education-icon img')].length === 1 && [...document.querySelectorAll('.education-icon img')].every(img => img.complete && img.naturalWidth > 0)`);
  const emblems = await evaluate(`[...document.querySelectorAll('.education-icon img')].map(img => ({width:img.getBoundingClientRect().width,height:img.getBoundingClientRect().height,fit:getComputedStyle(img).objectFit}))`);
  assert.equal(emblems.length, 1);
  for (const emblem of emblems) {
    assert.equal(emblem.width, emblem.height);
    assert.equal(emblem.fit, 'contain');
  }
  assert.equal(await evaluate(`document.querySelectorAll('.research-interests').length`), 0);
  console.log('PASS: undergraduate education emblem loads as a square, with no duplicate interest list');

  for (const [filter, count] of [['accepted',3], ['preprint',1], ['all',4]]) {
    await evaluate(`document.querySelector('[data-filter="${filter}"]').click()`);
    assert.equal(await evaluate(`document.querySelectorAll('.publication-card:not([hidden])').length`), count);
    assert.equal(await evaluate(`document.querySelector('.publication-count').textContent`), `${count} ${count === 1 ? 'paper' : 'papers'}`);
  }
  console.log('PASS: four cards, with three published papers and one preprint');
  assert.deepEqual(await evaluate(`[...document.querySelectorAll('.service-list li')].map(item => item.textContent.trim())`),
    ['ICLR(2027)', 'AAAI(2027)', 'ICME(2026)', 'IJCNN(2026,2027)', 'PRCV(2026)']);

  const sections = await evaluate(`[...document.querySelectorAll('.section-nav a[href^="/#"]')].map(link => link.hash.slice(1))`);
  assert(sections.includes('writing'));
  for (const width of [1440,390]) {
    await send('Emulation.setDeviceMetricsOverride', {width, height: width === 390 ? 844 : 1100, deviceScaleFactor: 1, mobile: width === 390});
    for (const section of sections) {
      await navigate(section);
      if (section === 'writing') {
        await waitFor(`[...document.querySelectorAll('#writing h2 img, .writing-nav-link img')].every(img => img.complete && img.naturalWidth > 0)`);
      }
      if (section === 'awards') {
        await waitFor(`[...document.querySelectorAll('.award-list .recognition-mark img')].every(img => img.complete && img.naturalWidth > 0)`);
      }
      if (section === 'news') await evaluate(`document.querySelector('.news-window').scrollTop = 0`);
      await screenshot(`${width}-${section}`);
      if (section === 'news') {
        const pageScroll = await evaluate('scrollY');
        await evaluate(`document.querySelector('.news-window').focus({preventScroll: true})`);
        await send('Input.dispatchKeyEvent', {type: 'keyDown', key: 'PageDown', code: 'PageDown', windowsVirtualKeyCode: 34});
        await send('Input.dispatchKeyEvent', {type: 'keyUp', key: 'PageDown', code: 'PageDown', windowsVirtualKeyCode: 34});
        await waitFor(`document.querySelector('.news-window').scrollTop > 50`);
        assert.equal(await evaluate('scrollY'), pageScroll);
      }
      if (section === 'publications') {
        await evaluate(`document.querySelector('[data-filter="preprint"]').click()`);
        await waitFor(`document.querySelector('.publication-card[data-status="preprint"] img').naturalWidth > 0`);
        await screenshot(`${width}-preprint`);
        await evaluate(`document.querySelector('[data-filter="all"]').click()`);
      }
    }
  }
  assert.equal(await evaluate(`location.hash`), '#service');
  assert.equal(await evaluate(`document.querySelector('.section-nav a[aria-current]').textContent.trim()`), 'Service');
  console.log('PASS: every section and last-section navigation on desktop and mobile');

  await evaluate(`(() => {
    const toggle = document.querySelector('.tone-toggle');
    toggle.focus();
    toggle.click();
  })()`);
  assert.equal(await evaluate(`document.querySelector('[data-tone-control]').open`), true);
  await send('Input.dispatchKeyEvent', {type:'keyDown',key:'Escape',code:'Escape',windowsVirtualKeyCode:27});
  assert.equal(await evaluate(`document.querySelector('[data-tone-control]').open`), false);
  assert.equal(await evaluate(`getComputedStyle(document.documentElement).scrollBehavior`), 'auto');
  const links = await evaluate(`[...document.querySelectorAll('.publication-card .publication-links a')].map(a=>({label:a.textContent.trim(),url:a.href}))`);
  assert.equal(links.length, 9);
  assert.equal(links.filter(link => link.label === '[PDF]').length, 3);
  assert.equal(links.filter(link => link.label === '[Code]').length, 1);
  assert.equal(links.filter(link => link.label === '[Project]').length, 1);
  assert.equal(links.filter(link => link.label === '[DOI]').length, 3);
  assert.equal(links.filter(link => link.label === '[IJCAI]').length, 1);
  assert(links.every(link => !link.url.includes('/abs/') && !link.url.includes('researchgate')));
  const marks = await evaluate(`({legend:getComputedStyle(document.querySelector('.publication-legend')).fontSize, author:getComputedStyle(document.querySelector('.publication-authors')).fontSize, superscript:getComputedStyle(document.querySelector('.publication-authors sup')).fontSize})`);
  assert(parseFloat(marks.legend) >= 14);
  assert(parseFloat(marks.author) >= 14);
  assert(parseFloat(marks.superscript) >= 12);
  const pdf = await evaluate(`fetch('/assets/papers/deepyolo-ijcnn-2026.pdf').then(async response => {
    const reader = response.body.getReader();
    const {value} = await reader.read();
    await reader.cancel();
    return {
      ok: response.ok,
      type: response.headers.get('content-type'),
      signature: new TextDecoder().decode(value?.slice(0, 5)),
    };
  })`);
  assert.equal(pdf.ok, true);
  assert(pdf.type.includes('application/pdf'));
  assert.equal(pdf.signature, '%PDF-');
  console.log('PASS: keyboard color control, reduced motion and direct IJCNN PDF response');
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
