/* ═══════════════════════════════════════════════════════════
                    wc_menu NUI bridge
   ═══════════════════════════════════════════════════════════ */

const WC_RESOURCE = (() => {
    // GetParentResourceName() injected by CFX
    if (typeof GetParentResourceName === 'function') return GetParentResourceName();
    return 'wc_menu';
})();

function wcPost(name, data = {}) {
    return fetch(`https://${WC_RESOURCE}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).then(r => r.json()).catch(() => ({ ok: false }));
}

window.wcPost = wcPost;
