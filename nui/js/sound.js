/* â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
                    wc_menu NUI sound player
   â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• */

const WCSound = {
    _map: {
        open:    'assets/sounds/menu_open.mp3',
        close:   'assets/sounds/menu_close.mp3',
        nav:     'assets/sounds/button.mp3',
        select:  'assets/sounds/selected.mp3',
        back:    'assets/sounds/button.mp3',
        confirm: 'assets/sounds/coins.mp3',
        error:   'assets/sounds/button.mp3',
    },
    _volume: 0.5,
    _cache: {},
    _lastPlayed: {},
    _minGap: {
        nav: 45,
        back: 45,
        error: 80,
    },

    play(name) {
        const src = this._map[name];
        if (!src) return;
        const now = performance.now();
        const minGap = this._minGap[name] || 0;
        if (minGap && this._lastPlayed[name] && now - this._lastPlayed[name] < minGap) return;
        this._lastPlayed[name] = now;

        const audio = this._cache[name] || new Audio(src);
        this._cache[name] = audio;
        audio.volume = this._volume;
        audio.currentTime = 0;
        audio.play().catch(() => {});
    }
};

window.WCSound = WCSound;

