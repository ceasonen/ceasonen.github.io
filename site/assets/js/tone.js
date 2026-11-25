(() => {
    const storageKey = 'cube-page-tone';
    const defaultHue = 205;
    const root = document.documentElement;
    const controls = [...document.querySelectorAll('[data-tone-control]')];

    function normalize(value) {
        return typeof value === 'string' && /^\d{1,3}$/.test(value) && Number(value) < 360
            ? Number(value)
            : defaultHue;
    }

    function display(value) {
        const hue = normalize(String(value));
        root.style.setProperty('--site-hue', hue);
        for (const control of controls) {
            control.querySelector('[data-tone-input]').value = hue;
            control.querySelector('[data-tone-value]').textContent = hue + '°';
        }
    }

    function remember(value) {
        try {
            if (value === null) localStorage.removeItem(storageKey);
            else localStorage.setItem(storageKey, String(value));
        } catch {
            // The control also works when storage is disabled.
        }
    }

    let savedHue = defaultHue;
    try {
        savedHue = normalize(localStorage.getItem(storageKey));
    } catch {
        // Use the default in browsers that restrict storage.
    }
    display(savedHue);

    for (const control of controls) {
        const dial = control.querySelector('[data-tone-dial]');
        const range = control.querySelector('[data-tone-input]');
        const summary = control.querySelector('summary');

        function pointerHue(event) {
            const bounds = dial.getBoundingClientRect();
            const x = event.clientX - (bounds.left + bounds.width / 2);
            const y = event.clientY - (bounds.top + bounds.height / 2);
            if (Math.hypot(x, y) < 5) return;
            const hue = (Math.round(Math.atan2(x, -y) * 180 / Math.PI) + 360) % 360;
            display(hue);
        }

        dial.addEventListener('pointerdown', event => {
            if (event.button !== 0 || !event.isPrimary) return;
            event.preventDefault();
            range.focus({ preventScroll: true });
            dial.setPointerCapture(event.pointerId);
            pointerHue(event);
        });
        dial.addEventListener('pointermove', event => {
            if (dial.hasPointerCapture(event.pointerId)) pointerHue(event);
        });
        dial.addEventListener('lostpointercapture', () => remember(range.value));
        range.addEventListener('input', () => {
            display(range.value);
            remember(range.value);
        });
        control.querySelector('[data-tone-reset]').addEventListener('click', () => {
            display(defaultHue);
            remember(null);
        });
        control.addEventListener('keydown', event => {
            if (event.key === 'Escape' && control.open) {
                event.preventDefault();
                event.stopPropagation();
                control.open = false;
                summary.focus();
            }
        });
        document.addEventListener('click', event => {
            if (control.open && !control.contains(event.target)) control.open = false;
        });
        control.hidden = false;
    }
    window.addEventListener('storage', event => {
        if (event.key === storageKey) display(normalize(event.newValue));
    });
})();
