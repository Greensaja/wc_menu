--[[
    wc_menu input module
    Blocks conflicting controls while a menu is open.
    Native control dispatch is available as a fallback when browser input is not primary.
]]

local Input = {}
local active = false
local lastInputTime = 0
local heldKey = nil
local heldSince = 0

local KEY_MAP = {
    [Config.Keys.up]        = 'up',
    [Config.Keys.down]      = 'down',
    [Config.Keys.left]      = 'left',
    [Config.Keys.right]     = 'right',
    [Config.Keys.select]    = 'select',
    [Config.Keys.selectAlt] = 'select',
    [Config.Keys.back]      = 'back',
    [Config.Keys.backAlt]   = 'back',
    [Config.Keys.search]    = 'search',
    [Config.Keys.tab]       = 'tab',
    [Config.Keys.close]     = 'close',
}

local REPEATABLE = { up = true, down = true, left = true, right = true }

function Input.enable()
    if active then return end
    active = true
    wc.utils.log('Input enabled')

    Citizen.CreateThread(function()
        while active do
            Citizen.Wait(0)

            -- block conflicting native controls while menu is open
            DisableControlAction(0, 0x07CE1E61, true)  -- INPUT_NEXT_CAMERA
            DisableControlAction(0, 0xB2F377E8, true)  -- INPUT_LOOK_LR
            DisableControlAction(0, 0x6E4DD04A, true)  -- INPUT_LOOK_UD
            EnableControlAction(0, `INPUT_PUSH_TO_TALK`, true)

            if Config.BlockMovement then
                DisableControlAction(0, 0x8FD015D8, true)  -- INPUT_MOVE_LR
                DisableControlAction(0, 0xD27782E3, true)  -- INPUT_MOVE_UD
                DisableControlAction(0, 0x4BC2EC67, true)  -- INPUT_SPRINT
                DisableControlAction(0, 0xD9D0E1C0, true)  -- INPUT_JUMP
            end

            if not Config.BrowserInputPrimary then
                local now = GetGameTimer()

                for control, action in pairs(KEY_MAP) do
                    if IsControlJustPressed(0, control) then
                        Input.dispatch(action)
                        heldKey = REPEATABLE[action] and control or nil
                        heldSince = now
                        lastInputTime = now
                    elseif IsControlJustReleased(0, control) and heldKey == control then
                        heldKey = nil
                    end
                end

                -- handle held-key repeat
                if heldKey and IsControlPressed(0, heldKey) then
                    if now - heldSince > 400 and now - lastInputTime > Config.InputRepeatDelay then
                        Input.dispatch(KEY_MAP[heldKey])
                        lastInputTime = now
                    end
                else
                    heldKey = nil
                end
            end
        end
    end)
end

function Input.disable()
    active = false
    heldKey = nil
    wc.utils.log('Input disabled')
end

function Input.dispatch(action)
    if not action then return end
    wc.utils.log('Input action:', action)
    wc.nui.send('input', { action = action })
end

wc.input = Input
