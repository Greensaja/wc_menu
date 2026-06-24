# wc_menu — Developer Reference

Modern ornamental NUI menu library for RedM (Wild County RP).  
Drop-in for any script. No dependencies beyond `@wc_libs/init.lua`.

---

## Quick Start

```lua
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
```

---

## API Reference

### Open / Close

| Function | Description |
|---|---|
| `wc.menu.open(menu)` | Opens a menu. If one is already open, pushes the new one onto the stack. |
| `wc.menu.close()` | Closes the menu and clears the entire navigation stack. |
| `wc.menu.back()` | Goes back one level. Closes entirely if at root. |
| `wc.menu.isOpen()` | Returns `true` if any menu is open. |
| `wc.menu.currentId()` | Returns the `id` of the currently open menu, or `nil`. |

### Updates

| Function | Description |
|---|---|
| `wc.menu.update(patch)` | Merges `patch` into the current menu and re-renders. |
| `wc.menu.updateItem(id, patch)` | Updates a single item by `id` without closing the menu. |
| `wc.menu.toast(text, icon, ms)` | Shows a floating notification. No menu needed. |

### Builders

| Function | Description |
|---|---|
| `wc.menu.action(opts)` | Builds a button item with event/callback routing. |
| `wc.menu.purchase(opts)` | Builds a quantity item with purchase defaults. |

---

## `wc.menu.open(menu)` — Menu Options

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

## Item Types

### Button (default)

```lua
{
    id       = 'start',
    label    = 'Start Patrol',
    icon     = 'shield',            -- Font Awesome icon name
    image    = 'badges.png',        -- OR image from nui/assets/images/
    description = 'Begin route.',
    onSelect = function() end,
    confirm  = 'Are you sure?',     -- shows confirm dialog before onSelect fires
}
```

### Submenu

```lua
{
    id      = 'settings',
    label   = 'Settings',
    icon    = 'gear',
    type    = 'submenu',
    submenu = {                     -- table OR function returning table
        id    = 'settings_sub',
        title = 'Settings',
        items = { ... }
    }
}
```

Using a **function** for `submenu` means it's built fresh each time it opens (good for dynamic content):

```lua
submenu = function()
    return {
        id    = 'dynamic_sub',
        title = 'Live Data',
        items = buildItemsNow()
    }
end
```

### Checkbox

```lua
{
    id       = 'notif',
    label    = 'Notifications',
    icon     = 'bell',
    type     = 'checkbox',
    value    = true,                -- current state
    onChange = function(v) end,     -- v = true/false
}
```

### Slider

```lua
{
    id       = 'volume',
    label    = 'Volume',
    icon     = 'volume-high',
    type     = 'slider',
    min      = 0,
    max      = 100,
    step     = 5,
    value    = 60,
    onChange = function(v) end,     -- v = number
}
```

### Quantity

```lua
{
    id       = 'ammo',
    label    = 'Ammunition',
    icon     = 'boxes-stacked',
    type     = 'quantity',
    min      = 1,
    max      = 99,
    step     = 1,
    value    = 5,
    price    = { money = 2 },       -- shown as $2 in item row and preview
    onChange = function(v) end,     -- v = number; called on every +/- press
}
```

### Input

```lua
{
    id          = 'search',
    label       = 'Search',
    icon        = 'keyboard',
    type        = 'input',
    value       = '',
    placeholder = 'Type here...',
    onChange    = function(v) end,  -- v = string
}
```

### Select

```lua
{
    id       = 'difficulty',
    label    = 'Mode',
    icon     = 'list',
    type     = 'select',
    value    = 'normal',
    options  = {
        { value = 'easy',   label = 'Quiet'     },
        { value = 'normal', label = 'Standard'  },
        { value = 'hard',   label = 'High Risk' },
    },
    onChange = function(v) end,     -- v = selected option value
}
```

### Divider

```lua
{ type = 'divider' }
```

### Label

```lua
{ type = 'label', label = 'SECTION HEADER' }
```

---

## Common Item Fields

These work on **any** item type:

```lua
{
    -- Visual
    badge        = 12,              -- circular number badge (e.g. unread count)
    rarity       = 'legendary',     -- 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
    tags         = { 'New', 'Sale' }, -- small label pills in preview
    meta         = { Weight = '1kg', Type = 'Ammo' }, -- key/value pills in preview

    -- Stock info (display only)
    stock        = 50,              -- how many available
    owned        = 3,               -- how many player has
    limit        = 10,              -- max purchasable

    -- Locking
    disabled       = true,
    disabledReason = 'Requires Sheriff rank 3',  -- shown as toast + lock banner in preview
    status         = 'Locked',      -- shown as meta pill

    -- Price
    price = { money = 5 },
    price = { gold = 1 },
    price = { money = 10, gold = 1 },   -- multi-currency
    price = 5,                          -- shorthand for { money = 5 }
}
```

---

## Price Formats

```lua
-- Money
price = 5
price = { money = 5 }

-- Gold
price = { gold = 1 }

-- ROL
price = { rol = 50 }

-- Items
price = { item = 'pelt', quantity = 2, label = 'Pelts' }

-- Multiple currencies
price = { money = 10, gold = 1 }

-- Array form
price = { { money = 10 }, { gold = 1 } }
```

---

## Server & Client Events

Any item can fire an event on selection instead of (or alongside) `onSelect`:

```lua
{
    id          = 'buy_horse',
    label       = 'Buy Horse',
    type        = 'button',
    serverEvent = 'myshop:purchase',    -- triggers TriggerServerEvent
    clientEvent = 'myshop:localAction', -- triggers TriggerEvent
    args        = { item = 'horse', color = 'black' },
}
```

**Payload received by the event handler:**

```lua
RegisterNetEvent('myshop:purchase', function(payload)
    -- payload.menuId   = 'my_menu'
    -- payload.itemId   = 'buy_horse'
    -- payload.label    = 'Buy Horse'
    -- payload.type     = 'button'
    -- payload.value    = nil (or quantity for type='quantity')
    -- payload.price    = { { money = 500 } }
    -- payload.args     = { item = 'horse', color = 'black' }
    -- payload.index    = 3
end)
```

---

## Helper Builders

### `wc.menu.action(opts)`

Shorthand for building a button with event routing and optional job requirements:

```lua
wc.menu.action({
    id           = 'start_patrol',
    label        = 'Start Patrol',
    icon         = 'shield',
    serverEvent  = 'patrol:start',
    args         = { zone = 'armadillo' },
    requiredJob  = 'sheriff',
    requiredGrade = 2,
    confirm      = 'Begin patrol?',
})
```

### `wc.menu.purchase(opts)`

Shorthand for quantity items with purchase defaults:

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

## Live Updates

Update items while the menu is open (e.g. stock counter, badge count):

```lua
wc.menu.open({
    id    = 'reports',
    title = 'Reports',
    items = {
        { id = 'inbox', label = 'Inbox', icon = 'envelope', badge = 5 }
    }
})

-- 3 seconds later, update the badge without closing the menu:
SetTimeout(3000, function()
    wc.menu.updateItem('inbox', { badge = 6 })
end)
```

---

## Toast Notifications

Works whether a menu is open or not:

```lua
wc.menu.toast('Patrol started!',   'shield-check', 3000)
wc.menu.toast('Not enough money.', 'circle-xmark', 2500)
wc.menu.toast('Item purchased.',   'bag-shopping', 2000)
```

`icon` accepts a Font Awesome icon name **or** an image filename from `nui/assets/images/`.

---

## Locked / Disabled Items

Disabled items can still be highlighted so players can read the requirement:

```lua
{
    id             = 'special_mission',
    label          = 'Special Mission',
    icon           = 'lock',
    disabled       = true,
    disabledReason = 'Requires Sheriff grade 3',
    rarity         = 'legendary',
    description    = 'Unlocks at Sheriff grade 3.',
    tags           = { 'Requirement' },
}
```

**Dynamic lock** (check grade at open time via server callback):

```lua
-- server/main.lua
VORPcore.Callback.Register('myscript:getJob', function(source, cb)
    local char = VORPcore.getUser(source).getUsedCharacter
    cb({ job = tostring(char.job or ''), grade = tonumber(char.jobGrade) or 0 })
end)

-- client/main.lua
RegisterCommand('mymenu', function()
    local r    = VORPcore.Callback.TriggerAwait('myscript:getJob')
    local job  = r and r.job   or ''
    local grade = r and r.grade or 0

    wc.menu.open({
        id    = 'my_menu',
        title = 'My Menu',
        items = {
            {
                id             = 'locked_item',
                label          = 'Special Access',
                icon           = grade >= 3 and 'unlock' or 'lock',
                disabled       = grade < 3,
                disabledReason = grade < 3 and 'Requires Sheriff grade 3\n(yours: ' .. job .. ' ' .. grade .. ')' or nil,
                onSelect       = grade >= 3 and function()
                    wc.menu.toast('Access granted!', 'unlock', 1800)
                end or nil,
            }
        }
    })
end, false)
```

> **VORP callback tip:** Always pass a single table from `cb({...})`.  
> `cb(a, b)` silently drops `b` — only the first value survives `Citizen.Await`.

---

## Confirm Dialog

Any selectable item can require confirmation:

```lua
{
    id       = 'delete',
    label    = 'Delete Character',
    icon     = 'triangle-exclamation',
    confirm  = 'This cannot be undone. Proceed?',
    onSelect = function()
        -- only fires after player clicks Yes
    end
}
```

---

## Submenus — Navigation Pattern

```lua
wc.menu.open({
    id    = 'root',
    title = 'Main Menu',
    items = {
        {
            id      = 'sub',
            label   = 'Sub Menu',
            type    = 'submenu',
            submenu = {
                id    = 'sub_menu',
                title = 'Sub Menu',
                items = {
                    {
                        id       = 'back',
                        label    = 'Back',
                        icon     = 'arrow-left',
                        onSelect = function() wc.menu.back() end
                    }
                }
            }
        },
        {
            id       = 'close',
            label    = 'Close',
            icon     = 'door-open',
            onSelect = function() wc.menu.close() end
        }
    }
})
```

---

## Theme Presets

```lua
themePreset = 'default'     -- neutral
themePreset = 'sheriff'     -- deep red accent, heavy ornament
themePreset = 'doctor'      -- pale bone accent
themePreset = 'shop'        -- gold accent
themePreset = 'stable'      -- brown accent
themePreset = 'crafting'    -- amber accent, light ornament
themePreset = 'warning'     -- red accent, heavy ornament
```

Override individual theme values:

```lua
themePreset = 'shop',
theme = { accent = '#d4af37', scale = 0.95 }
```

---

## Layouts

```lua
layout = 'portrait'     -- tall, left-aligned (default)
layout = 'compact'      -- shorter, no title cartouche
layout = 'wide'         -- wider panel, centred
layout = 'dialog'       -- centred, confirm-style
```

---

## Keyboard Controls (In-Game)

| Key | Action |
|---|---|
| `W` / `↑` | Move up |
| `S` / `↓` | Move down |
| `A` / `←` | Decrease value (slider/quantity) |
| `D` / `→` | Increase value (slider/quantity) |
| `E` / `Enter` | Select item |
| `Q` / `Backspace` | Back / close |
| `ESC` | Close menu entirely |
| `TAB` | Tab / mode switch (if `onTab` set) |
| `/` | Open search/filter |

Mouse is also fully supported — click to select, scroll to navigate.

---

## Export API (from other resources)

```lua
-- Open
exports.wc_menu:OpenMenu(menu)

-- Close / Back
exports.wc_menu:CloseMenu()
exports.wc_menu:BackMenu()

-- Updates
exports.wc_menu:UpdateMenu(patch)
exports.wc_menu:UpdateItem(id, patch)

-- Builders
local item = exports.wc_menu:ActionItem(opts)
local item = exports.wc_menu:PurchaseItem(opts)

-- State
local open = exports.wc_menu:IsMenuOpen()
local id   = exports.wc_menu:CurrentMenuId()

-- Toast
exports.wc_menu:Toast('Message', 'icon', 2500)
```

---

## Events

### Listen for menu actions in your script

```lua
-- Menu opened
AddEventHandler('wc_menu:menu:opened', function(menuId) end)

-- Menu closed
AddEventHandler('wc_menu:menu:closed', function(menuId) end)

-- Item selected
AddEventHandler('wc_menu:menu:itemSelected', function(menuId, itemId) end)
```

### Push job data to keep locked items in sync

```lua
-- From your server script:
TriggerClientEvent('wc_menu:setPlayerJob', playerId, 'sheriff', 3)
-- wc_menu will auto-recalculate disabled states for any open menu
```

---

## Full Example — Shop Menu

```lua
RegisterCommand('shop', function()
    wc.menu.open({
        id          = 'general_store',
        title       = 'General Store',
        subtitle    = 'Armadillo',
        themePreset = 'shop',
        layout      = 'portrait',
        onClose     = function()
            print('Store closed')
        end,
        items = {
            { type = 'label', label = 'Consumables' },
            wc.menu.purchase({
                id          = 'bandage',
                label       = 'Bandage',
                image       = 'bandage.png',
                price       = { money = 3 },
                stock       = 100,
                max         = 10,
                description = 'Stops bleeding.',
                serverEvent = 'shop:purchase',
                args        = { sku = 'bandage' },
            }),
            wc.menu.purchase({
                id          = 'antibiotic',
                label       = 'Antibiotic',
                image       = 'antibiotic.png',
                price       = { money = 8 },
                stock       = 40,
                max         = 5,
                rarity      = 'uncommon',
                description = 'Cures infections.',
                serverEvent = 'shop:purchase',
                args        = { sku = 'antibiotic' },
            }),
            { type = 'divider' },
            { type = 'label', label = 'Equipment' },
            {
                id          = 'horse_gear',
                label       = 'Horse Gear',
                icon        = 'horse',
                type        = 'submenu',
                submenu     = {
                    id    = 'horse_gear_sub',
                    title = 'Horse Gear',
                    items = {
                        wc.menu.purchase({
                            id          = 'saddle',
                            label       = 'Saddle',
                            icon        = 'horse-saddle',
                            price       = { money = 150 },
                            max         = 1,
                            serverEvent = 'shop:purchase',
                            args        = { sku = 'saddle' },
                        }),
                        {
                            id       = 'back',
                            label    = 'Back',
                            icon     = 'arrow-left',
                            onSelect = function() wc.menu.back() end
                        }
                    }
                }
            },
            { type = 'divider' },
            {
                id       = 'close',
                label    = 'Leave Store',
                icon     = 'door-open',
                onSelect = function() wc.menu.close() end
            }
        }
    })
end, false)

-- Server-side handler
RegisterNetEvent('shop:purchase', function(payload)
    local src   = source
    local sku   = payload.args and payload.args.sku
    local qty   = payload.value or 1
    print(('[shop] %s buying %dx %s'):format(src, qty, sku))
    -- do your DB / inventory logic here
end)
```

---

## Tips & Gotchas

- **VORP callbacks:** Always `cb({ key = val })` — never `cb(a, b)`. Only the first argument survives `Citizen.Await`.
- **Submenu as function:** Use `submenu = function() return {...} end` when the items need fresh data each open.
- **Cache busting:** If you edit NUI files (`js/`, `css/`) and changes don't appear, bump the `?v=N` query string in `nui/index.html`.
- **`disabled` items are still navigable** — players can read the `disabledReason`. Use this for requirement transparency.
- **`confirm` + `serverEvent`:** The server event only fires after the player confirms. Safe for destructive actions.
- **`wc.menu.update()` vs `wc.menu.updateItem()`:** `update()` replaces the whole items list (resets cursor). `updateItem()` patches one item without moving the cursor.
