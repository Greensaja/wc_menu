--[[
    wc_menu debug test menu
    Enable with Config.EnableTestCommand = true, then run /wcmenutest.
]]

if Config.EnableTestCommand then
    local VORPcore = exports.vorp_core:GetCore()

    RegisterCommand('wcmenutest', function()
        local result = VORPcore.Callback.TriggerAwait('wc_menu:test:getJob')
        local job   = result and result.job   or ''
        local grade = result and result.grade or 0
        local isSheriffGrade3 = (job == 'sheriff') and (grade >= 3)

        wc.menu.open({
            id = 'wc_menu_test',
            title = 'WC Menu Test',
            subtitle = 'All Item Types',
            description = 'Debug-only menu for checking controls, callbacks, themes, and layouts.',
            themePreset = 'sheriff',
            layout = 'portrait',
            onTab = function()
                wc.menu.toast('Tab callback received', 'keyboard', 1800)
            end,
            items = {
                { type = 'label', label = 'Basic' },
                {
                    id = 'button',
                    label = 'Button',
                    image = 'wrist_bindings.png',
                    description = 'Calls onSelect.',
                    rarity = 'rare',
                    stock = 8,
                    owned = 1,
                    tags = { 'Preview', 'Image' },
                    onSelect = function()
                        wc.menu.toast('Button selected', 'circle-check', 1800)
                    end
                },
                {
                    id = 'submenu',
                    label = 'Submenu',
                    icon = 'folder-open',
                    type = 'submenu',
                    submenu = {
                        id = 'wc_menu_test_sub',
                        title = 'Submenu',
                        subtitle = 'Back Test',
                        items = {
                            { id = 'back_note', label = 'Use Q or Backspace', icon = 'arrow-left' },
                        }
                    }
                },
                {
                    id = 'checkbox',
                    label = 'Checkbox',
                    icon = 'square-check',
                    type = 'checkbox',
                    value = true,
                    onChange = function(v)
                        wc.menu.toast('Checkbox: ' .. tostring(v), 'square-check', 1200)
                    end
                },
                {
                    id = 'slider',
                    label = 'Slider',
                    icon = 'sliders',
                    type = 'slider',
                    min = 0,
                    max = 100,
                    step = 10,
                    value = 50,
                    onChange = function(v)
                        print('[wc_menu test] slider', v)
                    end
                },
                {
                    id = 'locked',
                    label = 'Locked Item',
                    icon = isSheriffGrade3 and 'unlock' or 'lock',
                    disabled = not isSheriffGrade3,
                    disabledReason = not isSheriffGrade3 and ('Requires Sheriff grade 3\n(yours: ' .. (job or 'none') .. ' ' .. (grade or 0) .. ')') or nil,
                    description = 'Only accessible to Sheriff grade 3 or above.',
                    tags = isSheriffGrade3 and { 'Unlocked' } or { 'Requirement', 'Locked' },
                    onSelect = isSheriffGrade3 and function()
                        wc.menu.toast('Access granted!', 'unlock', 1800)
                    end or nil,
                },
                {
                    id = 'quantity',
                    label = 'Quantity',
                    icon = 'boxes-stacked',
                    type = 'quantity',
                    min = 1,
                    max = 10,
                    value = 2,
                    price = { money = 5 },
                    onChange = function(v)
                        print('[wc_menu test] quantity', v)
                    end
                },
                {
                    id = 'input',
                    label = 'Input',
                    icon = 'keyboard',
                    type = 'input',
                    value = '',
                    placeholder = 'Type here',
                    onChange = function(v)
                        print('[wc_menu test] input', v)
                    end
                },
                {
                    id = 'select',
                    label = 'Select',
                    icon = 'list',
                    type = 'select',
                    value = 'normal',
                    options = {
                        { value = 'easy', label = 'Easy' },
                        { value = 'normal', label = 'Normal' },
                        { value = 'hard', label = 'Hard' },
                    },
                    onChange = function(v)
                        wc.menu.toast('Select: ' .. tostring(v), 'list', 1200)
                    end
                },
                {
                    id = 'confirm',
                    label = 'Confirm',
                    icon = 'triangle-exclamation',
                    confirm = 'Confirm dialog works?',
                    onSelect = function()
                        wc.menu.toast('Confirmed', 'check', 1600)
                    end
                },
                wc.menu.action({
                    id = 'client_event',
                    label = 'Client Event',
                    icon = 'bolt',
                    clientEvent = 'wc_menu:test:clientAction',
                    args = { source = 'debug_menu' },
                }),
                wc.menu.purchase({
                    id = 'server_purchase',
                    label = 'Server Purchase',
                    icon = 'dollar-sign',
                    price = { money = 1 },
                    max = 5,
                    serverEvent = 'wc_menu:test:serverPurchase',
                    args = { sku = 'debug_item' },
                }),
            }
        })
    end, false)

    AddEventHandler('wc_menu:test:clientAction', function(payload)
        wc.menu.toast('Client event payload OK', 'bolt', 1800)
        print('[wc_menu test] client payload', json.encode(payload))
    end)
end
