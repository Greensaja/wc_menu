--[[
    wc_menu sample command
    /sheriff  — demonstrates the menu library
]]

RegisterCommand('sheriff', function()
    -- Demo: live badge update 3 seconds after open
    SetTimeout(3000, function()
        if wc.menu.isOpen() and wc.menu.currentId() == 'sheriff_patrol' then
            wc.menu.updateItem('reports', { badge = 13 })
            wc.menu.toast('New report received!', 'armor.png', 2500)
        end
    end)

    wc.menu.open({
        id       = 'sheriff_patrol',
        title    = 'Sheriff Patrol',
        subtitle = 'Armadillo Patrol',
        items = {
            {
                id          = 'start',
                label       = 'Start Patrol',
                image       = 'badges.png',
                description = 'Begin your assigned patrol route.',
                confirm     = 'This will begin your patrol. Proceed?',
                onSelect    = function()
                    wc.menu.close()
                    wc.menu.toast('Patrol started!', 'badges.png', 3000)
                end,
            },
            {
                id      = 'reports',
                label   = 'Patrol Reports',
                image   = 'armor.png',
                badge   = 12,
                type    = 'submenu',
                submenu = function()
                    return {
                        id    = 'sheriff_reports',
                        title = 'Patrol Reports',
                        items = {
                            { id = 'daily',  label = 'Daily Report',  image = 'bandage.png',
                              onSelect = function() print('[wc_menu sample] Daily Report') end },
                            { id = 'weekly', label = 'Weekly Report', image = 'ammo.png',
                              onSelect = function() print('[wc_menu sample] Weekly Report') end },
                            { id = 'back',   label = 'Back',          icon  = 'arrow-left',
                              onSelect = function() wc.menu.back() end },
                        }
                    }
                end,
            },
            {
                id      = 'notif',
                label   = 'Notifications',
                image   = 'antibiotic.png',
                type    = 'checkbox',
                value   = true,
                onChange = function(v)
                    print('[wc_menu sample] Notifications:', v)
                end,
            },
            {
                id      = 'volume',
                label   = 'Radio Volume',
                image   = 'accessories.png',
                type    = 'slider',
                min     = 0, max = 100, step = 5, value = 60,
                onChange = function(v)
                    print('[wc_menu sample] Radio volume:', v)
                end,
            },
            { type = 'divider' },
            {
                id      = 'difficulty',
                label   = 'Patrol Mode',
                image   = 'ankle_bindings.png',
                type    = 'select',
                value   = 'normal',
                options = {
                    { value = 'easy',   label = 'Quiet'    },
                    { value = 'normal', label = 'Standard' },
                    { value = 'hard',   label = 'High Risk' },
                },
                onChange = function(v)
                    print('[wc_menu sample] Patrol mode:', v)
                end,
            },
            { type = 'divider' },
            {
                id       = 'close',
                label    = 'Close',
                icon     = 'door-open',
                onSelect = function() wc.menu.close() end,
            },
        }
    })
end, false)
