// Single-page navigation: keyboard-friendly menu and section highlighting.
const menuButton = document.querySelector('.nav-toggle');
const menu = document.querySelector('#section-nav');
const links = [...document.querySelectorAll('.section-nav a[href*="#"]')];

menuButton?.addEventListener('click', () => {
    const open = menuButton.getAttribute('aria-expanded') !== 'true';
    menuButton.setAttribute('aria-expanded', String(open));
    menu.classList.toggle('is-open', open);
});

links.forEach(link => link.addEventListener('click', () => {
    menuButton?.setAttribute('aria-expanded', 'false');
    menu.classList.remove('is-open');
}));

// One set of cards, as in WowPage; filtering never duplicates paper content.
const publicationFilters = [...document.querySelectorAll('.publication-filter')];
const publicationCards = [...document.querySelectorAll('.publication-card')];
const publicationCount = document.querySelector('.publication-count');
publicationFilters.forEach(button => button.addEventListener('click', () => {
    const filter = button.dataset.filter;
    publicationFilters.forEach(item => item.setAttribute('aria-pressed', String(item === button)));
    publicationCards.forEach(card => {
        card.hidden = filter !== 'all' && card.dataset.status !== filter;
    });
    const count = publicationCards.filter(card => !card.hidden).length;
    if (publicationCount) publicationCount.textContent = `${count} ${count === 1 ? 'paper' : 'papers'}`;
    scheduleNavigationUpdate();
}));
document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menuButton?.getAttribute('aria-expanded') === 'true') {
        menuButton.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
        menuButton.focus();
    }
});

// A short final section cannot reach the header at the bottom of the page.
// Use document position, rather than a narrow IntersectionObserver band.
const sectionLinks = links.map(link => ({
    link,
    section: document.querySelector(new URL(link.href).hash)
})).filter(item => item.section);
let navigationFramePending = false;

function updateNavigation() {
    navigationFramePending = false;
    if (!sectionLinks.length) return;
    const marker = (document.querySelector('.site-header')?.getBoundingClientRect().bottom || 70) + 40;
    const atBottom = Math.ceil(window.scrollY + window.innerHeight) >= document.documentElement.scrollHeight - 2;
    let active = atBottom ? sectionLinks[sectionLinks.length - 1] : sectionLinks[0];
    if (!atBottom) {
        sectionLinks.forEach(item => {
            if (item.section.getBoundingClientRect().top <= marker) active = item;
        });
    }
    sectionLinks.forEach(item => {
        if (item === active) item.link.setAttribute('aria-current', 'location');
        else item.link.removeAttribute('aria-current');
    });
}

function scheduleNavigationUpdate() {
    if (navigationFramePending) return;
    navigationFramePending = true;
    window.requestAnimationFrame(updateNavigation);
}
window.addEventListener('scroll', scheduleNavigationUpdate, {passive: true});
window.addEventListener('resize', scheduleNavigationUpdate);
window.addEventListener('hashchange', scheduleNavigationUpdate);
scheduleNavigationUpdate();
