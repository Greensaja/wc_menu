--[[
    wc_menu server
    Currently minimal — reserved for server-validated menu callbacks (purchases, etc.)
]]

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print('^2[wc_menu]^7 v' .. wc.version .. ' loaded')
    end
end)

if Config.EnableTestCommand then
    RegisterNetEvent('wc_menu:test:serverPurchase', function(payload)
        print(('[wc_menu test] server payload from %s: %s'):format(source, json.encode(payload or {})))
    end)

    local VORPcore = exports.vorp_core:GetCore()
    VORPcore.Callback.Register('wc_menu:test:getJob', function(source, cb)
        local Character = VORPcore.getUser(source).getUsedCharacter
        cb({ job = tostring(Character.job or ''), grade = tonumber(Character.jobGrade) or 0 })
    end)
end
