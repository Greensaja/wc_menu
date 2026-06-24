--[[
    wc_menu config
    Server-wide defaults. Edit before deploying.
    Per-menu overrides go in the OpenMenu options table.
]]

Config = {}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       BEHAVIOR
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Register /wcmenutest. Keep false on production servers unless testing this resource.
Config.EnableTestCommand = false

-- Pause game when a menu is open (RDR2 native pause)
Config.PauseGame = false

-- Block player movement while menu is open
Config.BlockMovement = true

-- Browser input is the primary navigation path when NUI has keyboard focus.
-- Set false only if you need native control polling as the primary input source.
Config.BrowserInputPrimary = true

-- Auto-close menu when player moves too far from anchor point (meters)
-- Set to 0 to disable
Config.AutoCloseDistance = 0

-- Maximum items rendered per page before pagination kicks in
Config.ItemsPerPage = 4

-- Throttle for input repeat (ms) when holding arrow keys
Config.InputRepeatDelay = 180


-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       APPEARANCE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

Config.Theme = {
    -- Selection accent color (the red border on selected button).
    -- Anything CSS-valid. Set to '#f4ecd8' for pure B&W mode.
    accent = '#b22020',

    -- Frame ornament intensity: 'light' | 'medium' | 'heavy'
    -- Affects SVG ornament density on the panel frame.
    frameIntensity = 'heavy',

    -- Show the separate title cartouche above the panel
    -- false = title inside main panel (more compact)
    showTitleCartouche = true,

    -- Panel position: 'center' | 'left' | 'right' | 'top-right' | 'bottom-right' etc.
    position = 'left',

    -- Scale factor for the entire menu (0.8 = smaller, 1.2 = larger)
    scale = 1.0,

    -- Layout mode: 'portrait' | 'compact' | 'wide' | 'dialog'
    layout = 'portrait',
}

Config.ThemePresets = {
    default = {},
    sheriff = { accent = '#b22020', frameIntensity = 'heavy' },
    doctor = { accent = '#d9d3bf', frameIntensity = 'medium' },
    shop = { accent = '#c59b45', frameIntensity = 'medium' },
    stable = { accent = '#9f7a4f', frameIntensity = 'medium' },
    crafting = { accent = '#b88a3d', frameIntensity = 'light' },
    warning = { accent = '#c43d2d', frameIntensity = 'heavy' },
}

Config.Layouts = {
    portrait = { layout = 'portrait', showTitleCartouche = true },
    compact = { layout = 'compact', showTitleCartouche = false, scale = 0.92 },
    wide = { layout = 'wide', showTitleCartouche = true, position = 'center' },
    dialog = { layout = 'dialog', showTitleCartouche = false, position = 'center' },
}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       KEYBINDINGS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- RedM control IDs. See: https://docs.fivem.net/docs/game-references/controls/
Config.Keys = {
    up        = 0xE6F612E4,  -- UP arrow / W
    down      = 0x6319DB71,  -- DOWN arrow / S
    left      = 0xA65EBAB4,  -- LEFT arrow / A
    right     = 0xDEB34313,  -- RIGHT arrow / D
    select    = 0xC7B5340A,  -- ENTER
    selectAlt = 0x951950BB,  -- E
    back      = 0x4CC0E2FE,  -- BACKSPACE
    backAlt   = 0xDE794E3E,  -- Q
    search    = 0x9959A6F0,  -- /
    tab       = 0xB238FE0B,  -- TAB (mode switch)
    close     = 0xCEFD9220,  -- ESC
}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       SOUNDS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- Use native RDR2 sound names. Set false to disable a sound.
Config.Sounds = {
    open    = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Shop_Transition_Fade_Screen' },
    close   = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Back' },
    nav     = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Nav_Up_Down' },
    select  = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Select' },
    back    = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Back' },
    error   = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Error' },
    confirm = { audioRef = 'HUD_SHOP_SOUNDSET',           audioName = 'Purchase' },
}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       FOOTER HINTS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- Floating button hints in bottom-right of screen.
-- Per-menu overrides allowed via menu.hints
Config.ShowHints = true

Config.Hints = {
    position = 'bottom-right',
    default = {
        { key = 'E',   label = 'Select' },
        { key = 'Q',   label = 'Back' },
        { key = '/',   label = 'Search' },
        { key = 'ESC', label = 'Close', dim = true },
    }
}

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--                       DEBUG
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

Config.Debug = true                  -- enable console logging
Config.ShowFPSCounter = true         -- dev only

