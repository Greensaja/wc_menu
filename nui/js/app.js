/* ═══════════════════════════════════════════════════════════
                    wc_menu NUI entry point
   ═══════════════════════════════════════════════════════════ */

const root = document.getElementById('wc-root');
const hints = document.getElementById('wc-hints');

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (!action) return;

    switch (action) {
        case 'open': {
            WCSound.play('open');
            WCMenu.init(data);
            root.classList.remove('wc-hidden', 'closing');
            root.classList.add('opening');
            break;
        }
        case 'update': {
            WCMenu.updatePayload(data);
            break;
        }
        case 'close': {
            WCSound.play('close');
            root.classList.remove('opening');
            root.classList.add('closing');
            setTimeout(() => {
                root.classList.add('wc-hidden');
                hints.classList.add('wc-hidden');
            }, 150);
            break;
        }
        case 'input': {
            switch (data?.action) {
                case 'up':     WCSound.play('nav'); WCMenu.moveUp(); break;
                case 'down':   WCSound.play('nav'); WCMenu.moveDown(); break;
                case 'left':   WCMenu.moveLeft(); break;
                case 'right':  WCMenu.moveRight(); break;
                case 'select': WCMenu.activate(); break;
                case 'search': WCMenu.activateSearch(); break;
                case 'tab':    WCMenu.tab(); break;
                case 'back':
                    if (WCMenu.state.searchActive) { WCMenu.deactivateSearch(); }
                    else if (WCMenu.state.confirming) { WCMenu._confirmNo(); }
                    else { WCSound.play('back'); wcPost('back'); }
                    break;
                case 'close':
                    if (WCMenu.state.searchActive) { WCMenu.deactivateSearch(); }
                    else if (WCMenu.state.confirming) { WCMenu._confirmNo(); }
                    else { wcPost('close'); }
                    break;
            }
            break;
        }
        case 'toast': {
            WCToast.show(data.text, data.icon, data.duration);
            break;
        }
    }
});

// Tell Lua the NUI is ready (closes the bootstrap race)
document.addEventListener('DOMContentLoaded', () => {
    wcPost('ready');
});

// ─── KEYBOARD NAVIGATION ─────────────────────────────────
// SetNuiFocus(true,true) routes keyboard to the browser, so
// we handle it here exactly like jo_libs does.

let _keyHeld = null;
let _keyRepeatTimer = null;

function _handleKey(key) {
    if (root.classList.contains('wc-hidden')) return;
    switch (key) {
        case 'ArrowUp':
        case 'w':
        case 'W':
            WCSound.play('nav'); WCMenu.moveUp(); break;
        case 'ArrowDown':
        case 's':
        case 'S':
            WCSound.play('nav'); WCMenu.moveDown(); break;
        case 'ArrowLeft':
        case 'a':
        case 'A':
            WCMenu.moveLeft(); break;
        case 'ArrowRight':
        case 'd':
        case 'D':
            WCMenu.moveRight(); break;
        case 'Enter':
        case 'e':
        case 'E':
            WCMenu.activate(); break;
        case 'Tab':
            WCMenu.tab(); break;
        case 'Escape':
            if (WCMenu.state.confirming) { WCMenu._confirmNo(); }
            else { WCSound.play('close'); wcPost('close'); }
            break;
        case 'Backspace':
        case 'q':
        case 'Q':
            if (WCMenu.state.confirming) { WCMenu._confirmNo(); }
            else { WCSound.play('back'); wcPost('back'); }
            break;
        case '/':
            WCMenu.activateSearch();
            break;
    }
}

document.addEventListener('keydown', (e) => {
    if (root.classList.contains('wc-hidden')) return;
    // Search input handles its own keys via stopPropagation; outer handler steps aside
    if (WCMenu.state.searchActive) return;
    e.preventDefault();

    if (e.repeat) return; // browser repeat — handled by our own timer below

    _handleKey(e.key);

    // start hold-repeat for navigation keys
    const repeatable = ['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','w','s','a','d','W','S','A','D'];
    if (repeatable.includes(e.key)) {
        _keyHeld = e.key;
        clearTimeout(_keyRepeatTimer);
        _keyRepeatTimer = setTimeout(function repeat() {
            if (_keyHeld) {
                _handleKey(_keyHeld);
                _keyRepeatTimer = setTimeout(repeat, 120);
            }
        }, 350);
    }
});

document.addEventListener('keyup', (e) => {
    if (e.key === _keyHeld) {
        _keyHeld = null;
        clearTimeout(_keyRepeatTimer);
    }
});

// Mouse wheel navigation: one wheel step moves the menu selection and scroll window.
let _lastWheelAt = 0;

document.addEventListener('wheel', (e) => {
    if (root.classList.contains('wc-hidden')) return;
    if (WCMenu.state.searchActive || WCMenu.state.confirming) return;

    e.preventDefault();

    const now = Date.now();
    if (now - _lastWheelAt < 80) return;
    _lastWheelAt = now;

    if (e.deltaY > 0) {
        WCSound.play('nav');
        WCMenu.moveDown();
    } else if (e.deltaY < 0) {
        WCSound.play('nav');
        WCMenu.moveUp();
    }
}, { passive: false });

// ─── TOAST ───────────────────────────────────────────────────
const WCToast = {
    show(text, icon, duration) {
        const container = document.getElementById('wc-toast-container');
        const el = document.createElement('div');
        el.className = 'wc-toast';
        const iconHtml = icon
            ? (icon.endsWith('.png')
                ? `<img src="assets/images/${WCToast._escape(icon)}" class="wc-toast-img"> `
                : `<i class="fa-solid fa-${icon}"></i> `)
            : '';
        el.innerHTML = iconHtml + WCToast._escape(text);
        container.appendChild(el);

        requestAnimationFrame(() => el.classList.add('visible'));

        const hold = Math.max(800, (duration || 2500) - 400);
        setTimeout(() => {
            el.classList.remove('visible');
            el.classList.add('hiding');
            setTimeout(() => el.remove(), 400);
        }, hold);
    },
    _escape(s) {
        if (!s) return '';
        return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    }
};
window.WCToast = WCToast;

// ─── SUPPRESS ENGINE BADGE ───────────────────────────────────
// RedM/RAGE injects a "R★ CREATED" attribution element into the page.
// We own every element in this HTML; anything unknown gets hidden.
(function() {
    const _bodyOwned  = new Set(['wc-root', 'wc-hints', 'wc-toast-container']);
    const _rootOwned  = new Set(['wc-cartouche', 'wc-panel']);
    const _panelOwned = new Set(['wc-frame', 'wc-content']);

    function _purge() {
        Array.from(document.body.children).forEach(el => {
            if (!_bodyOwned.has(el.id)) el.style.setProperty('display', 'none', 'important');
        });
        const rootEl = document.getElementById('wc-root');
        if (rootEl) Array.from(rootEl.children).forEach(el => {
            if (!_rootOwned.has(el.id)) el.style.setProperty('display', 'none', 'important');
        });
        const panelEl = document.getElementById('wc-panel');
        if (panelEl) Array.from(panelEl.children).forEach(el => {
            if (!_panelOwned.has(el.id)) el.style.setProperty('display', 'none', 'important');
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        _purge();
        new MutationObserver(_purge).observe(document.body, { childList: true, subtree: true });
    });
})();
