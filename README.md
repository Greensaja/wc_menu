# wc_menu

Modern ornamental menu library for RedM.
Portrait, heavy ornamental frame, pure B&W with red selection accent. Vanilla JS, no dependencies.

---

## Install

1. Drop the `wc_menu` folder in your `resources/` directory.
2. Add `ensure wc_menu` to your `server.cfg` **before** any resource that depends on it.
3. Tweak `config.lua` for theme, keybinds, sounds, hints.

That's it. No `oxmysql`, no framework dependency, no NUI build step.

---

## API quick reference

`wc_menu` exposes a global `wc.menu` namespace on the client. Exports are also available:

```lua
wc.menu.open({...})          -- == exports.wc_menu:OpenMenu({...})
wc.menu.close()              -- == exports.wc_menu:CloseMenu()
wc.menu.back()               -- == exports.wc_menu:BackMenu()
wc.menu.update({...})        -- patch the open menu
wc.menu.updateItem(id, {...})-- patch one item by id
wc.menu.action({...})        -- build a standard action item
wc.menu.purchase({...})      -- build a server-validated quantity item
wc.menu.isOpen()             -- boolean
wc.menu.currentId()          -- string | nil
wc.menu.toast(text, icon)    -- show a toast
```

---

## Minimal example

```lua
RegisterCommand('sheriff', function()
    wc.menu.open({
        id        = 'sheriff_patrol',
        title     = 'Sheriff Patrol',
        subtitle  = 'Armadillo Patrol',
        items = {
            { id = 'cancel',  label = 'Cancel Patrol',  icon = 'xmark',
              description = 'Cancel your current patrol.',
              onSelect = function() print('cancelled') end },
            { id = 'reports', label = 'Patrol Reports', icon = 'file-lines',
              badge = 12,
              submenu = {
                  title = 'Patrol Reports',
                  items = {
                      { id = 'daily', label = 'Daily Report', image = 'book_opened.png' },
                      { id = 'weekly', label = 'Weekly Report', image = 'ammo.png' },
                  }
              } },
            { id = 'mine',    label = 'My Patrols',     icon = 'list',  badge = 47 },
            { id = 'route',   label = 'Change Route',   icon = 'location-dot',
              type = 'submenu' },
            { id = 'close',   label = 'Close',          icon = 'door-open',
              onSelect = function() wc.menu.close() end },
        }
    })
end, false)
```

---

## All item types

```lua
items = {
    -- BUTTON (default)
    { id='a', label='Begin patrol', icon='flag',
      onSelect = function() end },

    -- SERVER-VALIDATED ACTION
    { id='buy', label='Buy Supplies', icon='dollar-sign',
      serverEvent = 'my_resource:server:buySupplies',
      args = { sku = 'supplies_basic' } },

    -- CLIENT EVENT ACTION
    { id='inspect', label='Inspect', icon='magnifying-glass',
      clientEvent = 'my_resource:client:inspectThing',
      args = { target = 'notice_board' } },

    -- SUBMENU (chevron, opens child)
    { id='b', label='Settings', icon='gear', type='submenu',
      submenu = function() return { title='Settings', items={...} } end },

    -- CHECKBOX
    { id='c', label='Notifications', icon='bell', type='checkbox',
      value = true,
      onChange = function(v) print('toggled', v) end },

    -- SLIDER
    { id='d', label='Music Volume', icon='volume-high', type='slider',
      min = 0, max = 100, step = 5, value = 60,
      onChange = function(v) end },

    -- PURCHASE helper (quantity row + server event payload)
    wc.menu.purchase({
      id='e', label='Buy Ammo', icon='dollar-sign',
      min = 1, max = 99, value = 1,
      price = { money = 5 },
      serverEvent = 'my_shop:server:buyAmmo',
      args = { item = 'ammo_revolvernormal' }
    }),

    -- INPUT (text)
    { id='f', label='Player Name', icon='user', type='input',
      value = '', placeholder = 'type a name',
      onChange = function(v) end },

    -- SELECT (cycle options with left/right)
    { id='g', label='Difficulty', icon='gauge', type='select',
      value = 'normal',
      options = {
          { value='easy',   label='Easy' },
          { value='normal', label='Normal' },
          { value='hard',   label='Hard' },
      },
      onChange = function(v) end },

    -- DIVIDER (non-interactive separator)
    { type='divider' },

    -- LABEL (section header text)
    { type='label', label='Reports' },
}
```

---

## Theme override (per menu)

```lua
wc.menu.open({
    title = 'Vault',
    themePreset = 'shop',  -- default | sheriff | doctor | shop | stable | crafting | warning
    layout = 'wide',       -- portrait | compact | wide | dialog
    theme = {
        accent = '#d4af37',         -- gold instead of red
        showTitleCartouche = false, -- compact, no banner above panel
        position = 'right',
    },
    items = { ... }
})
```

---

## Layout and theme presets

```lua
wc.menu.open({
    title = 'Doctor Tools',
    themePreset = 'doctor',
    layout = 'compact',
    itemsPerPage = 5,
    items = { ... }
})
```

Presets are resolved once when the menu opens, so they add no ongoing runtime cost.

---

## Server action payload

Items with `serverEvent` or `clientEvent` receive the same structured payload:

```lua
{
    menuId = 'shop',
    itemId = 'buy_ammo',
    index = 3,
    type = 'quantity',
    label = 'Buy Ammo',
    value = 4,
    price = { { money = 5 } },
    args = { item = 'ammo_revolvernormal' }
}
```

Always validate money, items, distance, job, and permissions on the server before granting rewards.

---

## Debug test menu

Set `Config.EnableTestCommand = true`, restart `wc_menu`, then run:

```text
/wcmenutest
```

The command opens a menu covering every supported item type and event path. Keep it disabled on production.

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

## Price syntax

Anywhere a `price` is accepted, you can pass:

```lua
price = 5                                   -- $5
price = { money = 10, gold = 1 }            -- $10 + 1 GOLD
price = {
    { item = 'pelt', quantity = 2, label = 'Pelt' },
    { money = 5 }
}                                           -- 2x PELT + $5
```

`wc.utils.formatPrice(price)` normalizes any of these into the canonical array form.

---

## Events (server- or client-side)

```lua
AddEventHandler('wc_menu:menu:opened',       function(menuId) end)
AddEventHandler('wc_menu:menu:closed',       function(menuId) end)
AddEventHandler('wc_menu:menu:itemSelected', function(menuId, itemId) end)
AddEventHandler('wc_menu:menu:itemHovered',  function(menuId, itemId) end)
AddEventHandler('wc_menu:menu:tab',          function(menuId, selectedIndex) end)
```

Legacy `wc_lib:menu:*` events are still emitted for older resources, but new scripts should use `wc_menu:menu:*`.

---

## Keys (default - change in `config.lua`)

| Key       | Action            |
|-----------|-------------------|
| Up / W    | Previous item     |
| Down / S  | Next item         |
| Left / A  | Decrease value    |
| Right / D | Increase value    |
| Enter / E | Select / confirm  |
| Backspace / Q | Back          |
| /         | Search            |
| Tab       | Switch mode (shops) |
| Esc       | Close             |

