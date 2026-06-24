# wc_menu

Modern ornamental NUI menu library for RedM (Wild County RP).  
Drop-in for any script. No dependencies beyond `@wc_libs/init.lua`.

---

## Install

1. Drop the `wc_menu` folder in your `resources/` directory.
2. Add `ensure wc_menu` to your `server.cfg` **before** any resource that depends on it.
3. Tweak `config.lua` for theme, keybinds, sounds, hints.

No `oxmysql`, no framework dependency, no NUI build step.

---

## API quick reference

`wc_menu` exposes a global `wc.menu` namespace on the client. Exports are also available:

```lua
wc.menu.open({...})            -- == exports.wc_menu:OpenMenu({...})
wc.menu.close()                -- == exports.wc_menu:CloseMenu()
wc.menu.back()                 -- == exports.wc_menu:BackMenu()
wc.menu.update({...})          -- patch the open menu (resets cursor)
wc.menu.updateItem(id, {...})  -- patch one item by id (cursor stays)
wc.menu.action({...})          -- build a standard action item
wc.menu.purchase({...})        -- build a server-validated quantity item
wc.menu.isOpen()               -- boolean
wc.menu.currentId()            -- string | nil
wc.menu.toast(text, icon, ms)  -- show a floating toast notification
```

---

## Minimal example

```lua
RegisterCommand('wcmenutest', function()
    wc.menu.open({
        id    = 'my_menu',
        title = 'My Menu',
        items = {
            {
                id       = 'hello',
                label    = 'Say Hello',
                icon     = 'comment',
                onSelect = function()
                    wc.menu.toast('Hello!', 'check', 2000)
                end
            },
            {
                id       = 'close',
                label    = 'Close',
                icon     = 'door-open',
                onSelect = function() wc.menu.close() end
            }
        }
    })
end, false)
```

---

## All `wc.menu.open` options

```lua
wc.menu.open({
    id           = 'shop_main',         -- string; unique ID (auto-generated if omitted)
    title        = 'General Store',     -- string; REQUIRED
    subtitle     = 'Armadillo',         -- string; secondary header
    description  = 'Buy supplies.',     -- string; tertiary text
    layout       = 'portrait',          -- 'portrait' | 'compact' | 'wide' | 'dialog'
    themePreset  = 'shop',              -- see Theme Presets section
    theme        = { accent = '#fff' }, -- overrides preset (see Theme Options)
    itemsPerPage = 6,                   -- items before pagination (default: Config.ItemsPerPage)
    hints        = { ... },             -- custom footer hints (default: Config.Hints.default)
    onTab        = function(data) end,  -- called when TAB is pressed
    onOpen       = function() end,      -- called after menu opens
    onClose      = function() end,      -- called after menu closes
    items        = { ... },             -- array of item definitions
})
```

---

## Item types

### Button (default)

```lua
{
    id          = 'start',
    label       = 'Start Patrol',
    icon        = 'shield',            -- Font Awesome icon name
    image       = 'badges.png',        -- OR image from nui/assets/images/
    description = 'Begin route.',
    onSelect    = function() end,
    confirm     = 'Are you sure?',     -- shows confirm dialog before onSelect fires
}
```

### Submenu

```lua
{
    id      = 'settings',
    label   = 'Settings',
    icon    = 'gear',
    type    = 'submenu',
    submenu = {                        -- table OR function returning table
        id    = 'settings_sub',
        title = 'Settings',
        items = { ... }
    }
}
```

Use a **function** for `submenu` when items need fresh data each open:

```lua
submenu = function()
    return { id = 'dynamic_sub', title = 'Live Data', items = buildItemsNow() }
end
```

### Checkbox

```lua
{ id='notif', label='Notifications', icon='bell', type='checkbox',
  value = true, onChange = function(v) end }
```

### Slider

```lua
{ id='volume', label='Volume', icon='volume-high', type='slider',
  min = 0, max = 100, step = 5, value = 60,
  onChange = function(v) end }
```

### Quantity

```lua
{ id='ammo', label='Ammunition', icon='boxes-stacked', type='quantity',
  min = 1, max = 99, step = 1, value = 5,
  price = { money = 2 },
  onChange = function(v) end }
```

### Input

```lua
{ id='search', label='Search', icon='keyboard', type='input',
  value = '', placeholder = 'Type here...',
  onChange = function(v) end }
```

### Select

```lua
{ id='difficulty', label='Mode', icon='list', type='select',
  value = 'normal',
  options = {
      { value = 'easy',   label = 'Quiet'     },
      { value = 'normal', label = 'Standard'  },
      { value = 'hard',   label = 'High Risk' },
  },
  onChange = function(v) end }
```

### Divider / Label

```lua
{ type = 'divider' }
{ type = 'label', label = 'SECTION HEADER' }
```

---

## Common item fields

These work on **any** item type:

```lua
{
    -- Visual
    badge        = 12,                      -- circular number badge
    rarity       = 'legendary',             -- 'common'|'uncommon'|'rare'|'epic'|'legendary'
    tags         = { 'New', 'Sale' },       -- small label pills in preview
    meta         = { Weight = '1kg' },      -- key/value pills in preview

    -- Stock info (display only)
    stock        = 50,
    owned        = 3,
    limit        = 10,

    -- Locking
    disabled       = true,
    disabledReason = 'Requires Sheriff rank 3',
    status         = 'Locked',

    -- Price
    price = { money = 5 },
}
```

---

## Price formats

```lua
price = 5                                    -- $5 shorthand
price = { money = 5 }
price = { gold = 1 }
price = { rol = 50 }
price = { item = 'pelt', quantity = 2, label = 'Pelts' }
price = { money = 10, gold = 1 }             -- multi-currency
price = { { money = 10 }, { gold = 1 } }     -- array form
```

---

## Server & client events

Any item can fire an event on selection:

```lua
{
    id          = 'buy_horse',
    label       = 'Buy Horse',
    serverEvent = 'myshop:purchase',     -- triggers TriggerServerEvent
    clientEvent = 'myshop:localAction',  -- triggers TriggerEvent
    args        = { item = 'horse', color = 'black' },
}
```

**Payload received by the handler:**

```lua
RegisterNetEvent('myshop:purchase', function(payload)
    -- payload.menuId, payload.itemId, payload.label, payload.type
    -- payload.value (quantity for type='quantity', else nil)
    -- payload.price, payload.args, payload.index
end)
```

Always validate money, items, distance, job, and permissions on the server.

---

## Helper builders

### `wc.menu.action(opts)`

```lua
wc.menu.action({
    id            = 'start_patrol',
    label         = 'Start Patrol',
    icon          = 'shield',
    serverEvent   = 'patrol:start',
    args          = { zone = 'armadillo' },
    requiredJob   = 'sheriff',
    requiredGrade = 2,
    confirm       = 'Begin patrol?',
})
```

### `wc.menu.purchase(opts)`

```lua
wc.menu.purchase({
    id          = 'buy_ammo',
    label       = 'Ammo Box',
    icon        = 'box',
    price       = { money = 5 },
    max         = 20,
    serverEvent = 'shop:buy',
    args        = { sku = 'ammo_box' },
})
-- Defaults: min=1, max=99, step=1, confirm='Confirm purchase?', icon='dollar-sign'
```

---

## Live updates

```lua
wc.menu.updateItem('inbox', { badge = 6 })  -- patch without closing or moving cursor
wc.menu.update({ subtitle = 'Updated' })    -- patch whole menu (resets cursor)
```

---

## Theme presets

```lua
themePreset = 'default'     -- neutral
themePreset = 'sheriff'     -- deep red accent, heavy ornament
themePreset = 'doctor'      -- pale bone accent
themePreset = 'shop'        -- gold accent
themePreset = 'stable'      -- brown accent
themePreset = 'crafting'    -- amber accent, light ornament
themePreset = 'warning'     -- red accent, heavy ornament
```

Override individual values alongside a preset:

```lua
themePreset = 'shop',
theme = { accent = '#d4af37', scale = 0.95 }
```

---

## Layouts

```lua
layout = 'portrait'   -- tall, left-aligned (default)
layout = 'compact'    -- shorter, no title cartouche
layout = 'wide'       -- wider panel, centred
layout = 'dialog'     -- centred, confirm-style
```

---

## Hints override (per menu)

```lua
wc.menu.open({
    title = 'Buy Horse',
    hints = {
        { key = 'E',   label = 'Confirm' },
        { key = 'A/D', label = 'Quantity' },
        { key = 'Q',   label = 'Back' },
        { key = 'ESC', label = 'Close', dim = true },
    },
    items = { ... }
})
```

---

## Export API (from other resources)

```lua
exports.wc_menu:OpenMenu(menu)
exports.wc_menu:CloseMenu()
exports.wc_menu:BackMenu()
exports.wc_menu:UpdateMenu(patch)
exports.wc_menu:UpdateItem(id, patch)
local item = exports.wc_menu:ActionItem(opts)
local item = exports.wc_menu:PurchaseItem(opts)
local open = exports.wc_menu:IsMenuOpen()
local id   = exports.wc_menu:CurrentMenuId()
exports.wc_menu:Toast('Message', 'icon', 2500)
```

---

## Events

```lua
AddEventHandler('wc_menu:menu:opened',       function(menuId) end)
AddEventHandler('wc_menu:menu:closed',       function(menuId) end)
AddEventHandler('wc_menu:menu:itemSelected', function(menuId, itemId) end)
```

Push job data to auto-recalculate disabled states:

```lua
-- server-side
TriggerClientEvent('wc_menu:setPlayerJob', playerId, 'sheriff', 3)
```

---

## Keys (default — change in `config.lua`)

| Key               | Action                        |
|-------------------|-------------------------------|
| W / ↑             | Move up                       |
| S / ↓             | Move down                     |
| A / ←             | Decrease value                |
| D / →             | Increase value                |
| E / Enter         | Select / confirm              |
| Q / Backspace     | Back / close                  |
| ESC               | Close entirely                |
| TAB               | Tab / mode switch (if onTab)  |
| /                 | Search / filter               |

Mouse is also fully supported — click to select, scroll to navigate.

---

## Debug test menu

Set `Config.EnableTestCommand = true`, restart `wc_menu`, then run:

```
/wcmenutest
```

Opens a menu covering every supported item type and event path. Keep it disabled on production.

---

## Tips & Gotchas

- **VORP callbacks:** Always `cb({ key = val })` — never `cb(a, b)`. Only the first argument survives `Citizen.Await`.
- **Submenu as function:** Use `submenu = function() return {...} end` when items need fresh data each open.
- **`disabled` items are still navigable** — players can read `disabledReason`. Use this for requirement transparency.
- **`confirm` + `serverEvent`:** The server event only fires after the player confirms. Safe for destructive actions.
- **`wc.menu.update()` vs `wc.menu.updateItem()`:** `update()` replaces the whole items list (resets cursor). `updateItem()` patches one item without moving the cursor.
- **Cache busting:** If NUI changes don't appear, bump the `?v=N` query string in `nui/index.html`.
