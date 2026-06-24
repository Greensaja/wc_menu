/* â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
        wc_menu component renderers (vanilla JS, no framework)
   â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• */

const WCSvg = {

    // â”€â”€â”€ TITLE CARTOUCHE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    cartouche() {
        return `
        <svg viewBox="0 0 480 110" preserveAspectRatio="none">
            <rect x="14" y="14" width="452" height="82" fill="transparent" stroke="#e8e0d0" stroke-width="1.2"/>
            <rect x="20" y="20" width="440" height="70" fill="none" stroke="#e8e0d0" stroke-width="0.5"/>
            <!-- corners -->
            <path d="M 6 14 Q 6 6 14 6 L 30 6 M 14 6 Q 22 6 22 14 M 14 22 Q 6 22 6 30" fill="none" stroke="#e8e0d0" stroke-width="0.9"/>
            <path d="M 10 10 L 18 10 M 10 10 L 10 18" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="14" cy="14" r="1.4" fill="#e8e0d0"/>
            <path d="M 474 14 Q 474 6 466 6 L 450 6 M 466 6 Q 458 6 458 14 M 466 22 Q 474 22 474 30" fill="none" stroke="#e8e0d0" stroke-width="0.9"/>
            <path d="M 470 10 L 462 10 M 470 10 L 470 18" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="466" cy="14" r="1.4" fill="#e8e0d0"/>
            <path d="M 6 96 Q 6 104 14 104 L 30 104 M 14 104 Q 22 104 22 96 M 14 88 Q 6 88 6 80" fill="none" stroke="#e8e0d0" stroke-width="0.9"/>
            <path d="M 10 100 L 18 100 M 10 100 L 10 92" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="14" cy="96" r="1.4" fill="#e8e0d0"/>
            <path d="M 474 96 Q 474 104 466 104 L 450 104 M 466 104 Q 458 104 458 96 M 466 88 Q 474 88 474 80" fill="none" stroke="#e8e0d0" stroke-width="0.9"/>
            <path d="M 470 100 L 462 100 M 470 100 L 470 92" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="466" cy="96" r="1.4" fill="#e8e0d0"/>
            <!-- edges -->
            <path d="M 60 14 Q 100 6 140 14 Q 180 22 220 14 Q 240 8 260 14 Q 300 22 340 14 Q 380 6 420 14" fill="none" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="240" cy="10" r="2" fill="#e8e0d0"/>
            <circle cx="160" cy="16" r="1.2" fill="#e8e0d0"/>
            <circle cx="320" cy="16" r="1.2" fill="#e8e0d0"/>
            <path d="M 60 96 Q 100 104 140 96 Q 180 88 220 96 Q 240 102 260 96 Q 300 88 340 96 Q 380 104 420 96" fill="none" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="240" cy="100" r="2" fill="#e8e0d0"/>
            <path d="M 14 45 L 22 50 L 14 55 M 14 60 L 22 55" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
            <path d="M 466 45 L 458 50 L 466 55 M 466 60 L 458 55" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
        </svg>`;
    },

    // â”€â”€â”€ MAIN PANEL FRAME (height adapts) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    frame(heightPx) {
        const h = Math.max(300, heightPx || 560);
        // side ornament Y positions scale with frame height
        const ornamentY = [h * 0.25, h * 0.5, h * 0.75];
        const sideOrnaments = ornamentY.map(y => `
            <path d="M 6 ${y - 5} L 16 ${y} L 6 ${y + 5} M 6 ${y + 15} L 16 ${y + 10}" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
            <path d="M 474 ${y - 5} L 464 ${y} L 474 ${y + 5} M 474 ${y + 15} L 464 ${y + 10}" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
        `).join('');

        return `
        <svg viewBox="0 0 480 ${h}" preserveAspectRatio="none">
            <rect x="6" y="6" width="468" height="${h - 12}" fill="transparent" stroke="#e8e0d0" stroke-width="1.4"/>
            <rect x="12" y="12" width="456" height="${h - 24}" fill="none" stroke="#e8e0d0" stroke-width="0.5"/>
            <!-- corners (top-left, top-right, bottom-left, bottom-right) -->
            <path d="M 0 14 Q 0 0 14 0 L 32 0 M 14 0 Q 22 0 22 14 M 14 22 Q 0 22 0 32" fill="none" stroke="#e8e0d0" stroke-width="1"/>
            <path d="M 6 6 L 16 6 M 6 6 L 6 16" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="11" cy="11" r="1.6" fill="#e8e0d0"/>
            <path d="M 480 14 Q 480 0 466 0 L 448 0 M 466 0 Q 458 0 458 14 M 466 22 Q 480 22 480 32" fill="none" stroke="#e8e0d0" stroke-width="1"/>
            <path d="M 474 6 L 464 6 M 474 6 L 474 16" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="469" cy="11" r="1.6" fill="#e8e0d0"/>
            <path d="M 0 ${h - 14} Q 0 ${h} 14 ${h} L 32 ${h} M 14 ${h} Q 22 ${h} 22 ${h - 14} M 14 ${h - 22} Q 0 ${h - 22} 0 ${h - 32}" fill="none" stroke="#e8e0d0" stroke-width="1"/>
            <path d="M 6 ${h - 6} L 16 ${h - 6} M 6 ${h - 6} L 6 ${h - 16}" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="11" cy="${h - 11}" r="1.6" fill="#e8e0d0"/>
            <path d="M 480 ${h - 14} Q 480 ${h} 466 ${h} L 448 ${h} M 466 ${h} Q 458 ${h} 458 ${h - 14} M 466 ${h - 22} Q 480 ${h - 22} 480 ${h - 32}" fill="none" stroke="#e8e0d0" stroke-width="1"/>
            <path d="M 474 ${h - 6} L 464 ${h - 6} M 474 ${h - 6} L 474 ${h - 16}" stroke="#e8e0d0" stroke-width="0.7"/>
            <circle cx="469" cy="${h - 11}" r="1.6" fill="#e8e0d0"/>
            <!-- top + bottom running pattern -->
            <path d="M 60 6 Q 100 0 140 6 Q 180 12 220 6 Q 240 2 260 6 Q 300 12 340 6 Q 380 0 420 6" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="240" cy="4" r="1.6" fill="#e8e0d0"/>
            <path d="M 60 ${h - 6} Q 100 ${h} 140 ${h - 6} Q 180 ${h - 12} 220 ${h - 6} Q 240 ${h - 2} 260 ${h - 6} Q 300 ${h - 12} 340 ${h - 6} Q 380 ${h} 420 ${h - 6}" fill="none" stroke="#e8e0d0" stroke-width="0.6"/>
            <circle cx="240" cy="${h - 4}" r="1.6" fill="#e8e0d0"/>
            ${sideOrnaments}
        </svg>`;
    },

    // â”€â”€â”€ FOOTER NOTCH (down-arrow over divider) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    footerNotch() {
        return `<svg width="14" height="8" viewBox="0 0 14 8"><path d="M 0 0 L 7 8 L 14 0" fill="#0a0a0a" stroke="#6a6258" stroke-width="0.7"/></svg>`;
    }
};

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//                    ITEM COMPONENT RENDERERS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

const WCItem = {

    button(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        const badge = item.badge != null ? `<span class="wc-item-badge">${item.badge}</span>` : '';
        const price = item.price ? `<span class="wc-item-price">${WCItem._priceLabel(item.price)}</span>` : '';
        const chevron = item.type === 'submenu' ? `<i class="wc-item-chevron fa-solid fa-chevron-right" aria-hidden="true"></i>` : '';
        return `<div class="${cls}" data-index="${item.index}" data-type="${item.type}">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            ${price}
            ${badge}
            ${chevron}
        </div>`;
    },

    checkbox(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        const checked = item.value ? 'checked' : '';
        return `<div class="${cls}" data-index="${item.index}" data-type="checkbox">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            <span class="wc-checkbox ${checked}">${item.value ? '<i class="fa-solid fa-check"></i>' : ''}</span>
        </div>`;
    },

    slider(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        const min = item.min ?? 0, max = item.max ?? 100, val = item.value ?? min;
        const pct = ((val - min) / Math.max(1, max - min)) * 100;
        return `<div class="${cls}" data-index="${item.index}" data-type="slider">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            <span class="wc-slider">
                <span class="wc-slider-track"><span class="wc-slider-fill" style="width:${pct}%"></span></span>
                <span class="wc-slider-value">${val}</span>
            </span>
        </div>`;
    },

    quantity(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        const val = item.value ?? (item.min ?? 1);
        const unitChip = item.price
            ? `<span class="wc-qty-unit">${WCItem._escape(WCItem._priceLabel(item.price))}</span>`
            : '';
        return `<div class="${cls}" data-index="${item.index}" data-type="quantity">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            <div class="wc-qty-group">
                ${unitChip}
                <div class="wc-quantity">
                    <button type="button" class="wc-quantity-btn" data-action="dec"><i class="fa-solid fa-chevron-left"></i></button>
                    <span class="wc-quantity-value">${val}</span>
                    <button type="button" class="wc-quantity-btn" data-action="inc"><i class="fa-solid fa-chevron-right"></i></button>
                </div>
            </div>
        </div>`;
    },

    input(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        return `<div class="${cls}" data-index="${item.index}" data-type="input">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            <input type="text" class="wc-input" value="${WCItem._escape(item.value || '')}" placeholder="${WCItem._escape(item.placeholder || '')}"/>
        </div>`;
    },

    select(item, isSelected) {
        const cls = ['wc-item', isSelected ? 'selected' : '', item.disabled ? 'disabled' : ''].filter(Boolean).join(' ');
        const icon = WCItem._iconHtml(item);
        const opts = item.options || [];
        const curIdx = Math.max(0, opts.findIndex(o => o.value === item.value));
        const curLabel = opts[curIdx] ? opts[curIdx].label : 'â€”';
        return `<div class="${cls}" data-index="${item.index}" data-type="select">
            ${icon}
            <span class="wc-item-label">${WCItem._escape(item.label)}</span>
            <span class="wc-select-current">
                <i class="wc-select-arrow fa-solid fa-chevron-left" aria-hidden="true"></i>
                ${WCItem._escape(curLabel)}
                <i class="wc-select-arrow fa-solid fa-chevron-right" aria-hidden="true"></i>
            </span>
        </div>`;
    },

    divider() {
        return `<div class="wc-divider"></div>`;
    },

    label(item) {
        return `<div class="wc-label-row">${WCItem._escape(item.label)}</div>`;
    },

    // helpers
    _iconHtml(item) {
        const image = item.image || (/\.(png|jpg|jpeg|webp|gif)$/i.test(item.icon || '') ? item.icon : null);
        if (image) return `<img class="wc-item-icon wc-item-image" src="assets/images/${WCItem._escape(image)}" alt="">`;
        if (item.icon)  return `<i class="wc-item-icon fa-solid fa-${item.icon}" aria-hidden="true"></i>`;
        return '';
    },

    _escape(s) {
        if (s == null) return '';
        return String(s).replace(/[&<>"']/g, c => ({
            '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
        }[c]));
    },
    _priceLabel(priceArr) {
        return priceArr.map(p => {
            if (p.money != null) return `$${p.money}`;
            if (p.gold  != null) return `${p.gold} GOLD`;
            if (p.rol   != null) return `${p.rol} ROL`;
            if (p.item)          return `${p.quantity || 1}Ã— ${(p.label || p.item).toUpperCase()}`;
            return '';
        }).filter(Boolean).join(' + ');
    }
};

window.WCSvg = WCSvg;
window.WCItem = WCItem;

