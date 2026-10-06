// Put your custom JS code here

// CUSTOM THEME TOGGLE LOGIC
(function() {
    const light_mode_colors = ["#000000", "#000000", "#000000", "#798F00", "#868887", "#135E9C", "#3C8400", "#2421A9", "#F2920D"]
    const dark_mode_colors =  ["#CED9E2", "#CED9E2", "#CED9E2", "#FFE45F", "#868887", "#508DC0", "#78E77F", "#8482DD", "#FFBC5F"]

    function syncTheme() {
        const currentTheme = document.documentElement.getAttribute('data-bs-theme');
        const color_palette = currentTheme === "light" ? light_mode_colors : dark_mode_colors
        Array.from({ length: 9 }).forEach((_, i) => {
            document.documentElement.style.setProperty(`--terminal-r${i}-fill`, color_palette[i]);
        });
    }

    // Initial sync
    syncTheme();

    // Listen for theme changes
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-bs-theme') {
            syncTheme();
        }
        });
    });

    observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['data-bs-theme']
    });
})();

// Enlarge documentation screenshots without leaving the current page.
(function() {
    if (typeof HTMLDialogElement === 'undefined') return;

    let dialog;
    let image;
    let opener;

    function getDialog() {
        if (dialog) return dialog;

        dialog = document.createElement('dialog');
        dialog.className = 'docs-screenshot-lightbox';
        dialog.setAttribute('aria-label', 'Enlarged screenshot');

        const close = document.createElement('button');
        close.type = 'button';
        close.className = 'docs-screenshot-lightbox__close';
        close.setAttribute('aria-label', 'Close screenshot');
        close.textContent = '×';
        close.addEventListener('click', () => dialog.close());

        image = document.createElement('img');
        dialog.append(close, image);
        document.body.append(dialog);

        dialog.addEventListener('click', (event) => {
            if (event.target === dialog) dialog.close();
        });
        dialog.addEventListener('close', () => {
            if (opener) opener.focus();
            opener = null;
        });
        return dialog;
    }

    document.addEventListener('click', (event) => {
        const link = event.target.closest('[data-screenshot-lightbox]');
        if (!link || event.defaultPrevented || event.button !== 0 ||
            event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

        event.preventDefault();
        opener = link;
        const lightbox = getDialog();
        const preview = link.querySelector('img');
        image.src = link.href;
        image.alt = preview ? preview.alt : '';
        lightbox.showModal();
    });
})();
