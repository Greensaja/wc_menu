--[[
    wc_menu NUI bridge
    Two-way communication between Lua and the NUI iframe.
]]

local NUI = {}
local callbackHandlers = {}

function NUI.send(action, data)
    SendNUIMessage({
        action = action,
        data = data or {}
    })
end

function NUI.setFocus(focused, cursor)
    SetNuiFocus(focused or false, cursor or false)
    SetNuiFocusKeepInput(focused or false)
end

function NUI.registerCallback(name, handler)
    callbackHandlers[name] = handler
    RegisterNUICallback(name, function(data, cb)
        local ok, err = pcall(handler, data, cb)
        if not ok then
            wc.utils.error('NUI callback "' .. name .. '" errored: ' .. tostring(err))
            cb({ ok = false, error = tostring(err) })
        end
    end)
end

wc.nui = NUI

