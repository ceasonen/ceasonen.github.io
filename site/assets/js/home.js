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
document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menuButton?.getAttribute('aria-expanded') === 'true') {
        menuButton.setAttribute('aria-expanded', 'false');
        menu.classList.remove('is-open');
        menuButton.focus();
    }
});

if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(entries => {
        entries.filter(entry => entry.isIntersecting).forEach(entry => {
            links.forEach(link => {
                const active = new URL(link.href).hash === `#${entry.target.id}`;
                if (active) link.setAttribute('aria-current', 'location');
                else link.removeAttribute('aria-current');
            });
        });
    }, { rootMargin: '-15% 0px -65% 0px' });
    links.forEach(link => {
        const target = document.querySelector(new URL(link.href).hash);
        if (target) observer.observe(target);
    });
}
