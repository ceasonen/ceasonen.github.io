const links = [...document.querySelectorAll('.section-nav a[href*="#"]')];

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
    if (atBottom) {
        const target = sectionLinks.find(({link}) => link.hash === window.location.hash);
        if (target) {
            const top = target.section.getBoundingClientRect().top;
            if (top >= marker - 40 && top < window.innerHeight) active = target;
        }
    } else {
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
