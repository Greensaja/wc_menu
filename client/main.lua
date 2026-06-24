--[[
    wc_menu main menu controller
    Implements wc.menu.open, wc.menu.close, wc.menu.update, etc.
]]

local Menu = {}
local state = {
    current = nil,        -- the active menu definition
    stack = {},           -- navigation stack for breadcrumb / back
    isOpen = false,
    anchor = nil,
    playerJob = nil,
}

local EVENT_PREFIX = 'wc_menu:menu'
local LEGACY_EVENT_PREFIX = 'wc_lib:menu'

local function triggerMenuEvent(name, ...)
    TriggerEvent(EVENT_PREFIX .. ':' .. name, ...)
    TriggerEvent(LEGACY_EVENT_PREFIX .. ':' .. name, ...)
end

local function setGamePaused(paused)
    if Config.PauseGame and type(SetPauseMenuActive) == 'function' then
        SetPauseMenuActive(paused == true)
    end
end

local function getPlayerCoords()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function normalizePlayerJob(data, grade)
    if type(data) == 'string' then
        return { name = data, grade = grade }
    end

    if type(data) ~= 'table' then return nil end

    return {
        name = data.name or data.job or data.jobName or data.jobname,
        grade = data.grade or data.rank or data.jobGrade or data.jobgrade,
    }
end

local function getPlayerJob()
    if type(Config.GetPlayerJob) == 'function' then
        local ok, result, grade = pcall(Config.GetPlayerJob)
        if ok then
            local normalized = normalizePlayerJob(result, grade)
            if normalized and normalized.name then return normalized end
        end
    end

    return state.playerJob
end

local function titleCase(value)
    value = tostring(value or ''):gsub('_', ' ')
    return (value:gsub('(%a)([%w_%-]*)', function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

local function normalizeJobRequirement(item)
    local req = item.requirements or item.requirement or {}
    local job = item.requiredJob or item.job or req.job or req.name
    local grade = item.requiredGrade or item.grade or item.rank or req.grade or req.rank

    if type(job) == 'table' then
        return {
            jobs = job,
            reason = item.disabledReason or item.reason or item.lockedReason or req.reason,
        }
    end

    if not job then return nil end

    return {
        job = tostring(job),
        grade = grade,
        reason = item.disabledReason or item.reason or item.lockedReason or req.reason,
    }
end

local function evaluateJobRequirement(item)
    local req = normalizeJobRequirement(item)
    if not req then return false, nil end

    local playerJob = getPlayerJob()
    local playerName = playerJob and playerJob.name and tostring(playerJob.name):lower() or nil
    local playerGrade = playerJob and tonumber(playerJob.grade) or nil

    local requiredJob, requiredGrade = req.job, req.grade
    if req.jobs then
        requiredGrade = nil
        for jobName, jobGrade in pairs(req.jobs) do
            if playerName and playerName == tostring(jobName):lower() then
                requiredJob = tostring(jobName)
                requiredGrade = jobGrade
                break
            end
            requiredJob = requiredJob or tostring(jobName)
            requiredGrade = requiredGrade or jobGrade
        end
    end

    local requiredName = requiredJob and tostring(requiredJob):lower() or nil
    local gradeNumber = tonumber(requiredGrade)
    local missingJob = not playerName or playerName ~= requiredName
    local missingGrade = gradeNumber and ((not playerGrade) or playerGrade < gradeNumber)

    if not missingJob and not missingGrade then return false, nil end

    local reason = req.reason
    if not reason then
        reason = ('Requires %s'):format(titleCase(requiredJob))
        if gradeNumber then reason = reason .. (' rank %s'):format(gradeNumber) end
    end

    return true, reason
end

local function buildActionPayload(menu, item, data)
    return {
        menuId = menu.id,
        itemId = item.id,
        index = data and data.index or item.index,
        type = item.type or 'button',
        label = item.label,
        value = item.value,
        price = item.price and wc.utils.formatPrice(item.price) or nil,
        args = item.args or item.data or item.metadata,
    }
end

local function resolveTheme(menu)
    local parent = state.stack[#state.stack]
    local layoutName = menu.layout or menu.layoutPreset or (menu.theme and menu.theme.layout) or
        (parent and (parent.layout or parent.layoutPreset or (parent.theme and parent.theme.layout))) or
        Config.Theme.layout or 'portrait'
    local themePresetName = menu.themePreset or (parent and parent.themePreset) or 'default'
    local theme = wc.utils.tableMerge(Config.Theme, Config.Layouts[layoutName] or {})
    theme = wc.utils.tableMerge(theme, Config.ThemePresets[themePresetName] or {})
    if parent and parent.theme and not menu.theme then
        theme = wc.utils.tableMerge(theme, parent.theme)
    end
    theme = wc.utils.tableMerge(theme, menu.theme or {})
    theme.layout = theme.layout or layoutName
    return theme
end

-- ═══════════════════════════════════════════════════════════
--                    INTERNAL HELPERS
-- ═══════════════════════════════════════════════════════════

local function validateMenu(menu)
    assert(type(menu) == 'table', 'wc.menu.open: menu must be a table')
    assert(menu.title, 'wc.menu.open: menu.title is required')
    menu.id = menu.id or wc.utils.generateId('menu')
    menu.items = menu.items or {}
    menu.subtitle = menu.subtitle or ''
    menu.description = menu.description or ''
    return menu
end

local function prepareItemsForNUI(items)
    local prepared = {}
    for i, item in ipairs(items) do
        local requirementLocked, requirementReason = evaluateJobRequirement(item)
        local prep = {
            index = i,
            id = item.id or ('item_' .. i),
            type = wc.utils.validateItemType(item.type),
            label = item.label or '',
            description = item.description,
            icon = item.icon,
            image = item.image,
            badge = item.badge,
            confirm = item.confirm,
            disabled = item.disabled or requirementLocked or false,
            disabledReason = item.disabledReason or item.reason or item.lockedReason or requirementReason,
            status = item.status or (requirementLocked and 'Locked' or nil),
            rarity = item.rarity,
            stock = item.stock,
            owned = item.owned,
            limit = item.limit,
            tags = item.tags,
            meta = item.meta or item.metadata,
            -- type-specific
            value = item.value,
            min = item.min,
            max = item.max,
            step = item.step,
            options = item.options,
            placeholder = item.placeholder,
            price = item.price and wc.utils.formatPrice(item.price) or nil,
        }
        prepared[#prepared + 1] = prep
    end
    return prepared
end

local function getBreadcrumb()
    local crumbs = {}
    for _, m in ipairs(state.stack) do
        crumbs[#crumbs + 1] = m.title
    end
    if state.current then
        crumbs[#crumbs + 1] = state.current.title
    end
    return crumbs
end

local function buildPayload(menu)
    return {
        id = menu.id,
        title = menu.title,
        subtitle = menu.subtitle,
        description = menu.description,
        breadcrumb = getBreadcrumb(),
        items = prepareItemsForNUI(menu.items),
        itemsPerPage = menu.itemsPerPage or Config.ItemsPerPage or 7,
        hints = Config.ShowHints and (menu.hints or Config.Hints.default) or {},
        hintPosition = menu.hintPosition or (Config.Hints and Config.Hints.position) or 'bottom-right',
        theme = resolveTheme(menu),
        showBackButton = #state.stack > 0,
    }
end

-- ═══════════════════════════════════════════════════════════
--                    PUBLIC API
-- ═══════════════════════════════════════════════════════════

--- Open a menu.
---@param menu table The menu definition
function Menu.open(menu)
    menu = validateMenu(menu)

    if state.isOpen and state.current then
        -- pushing a submenu
        state.stack[#state.stack + 1] = state.current
    else
        -- opening a fresh menu
        state.stack = {}
        state.isOpen = true
        state.anchor = Config.AutoCloseDistance > 0 and getPlayerCoords() or nil
        wc.nui.setFocus(true, true)
        wc.input.enable()
        wc.sound.open()
        setGamePaused(true)
    end

    state.current = menu

    if #state.stack == 0 and GetResourceState('fx-hud') == 'started' then
        exports['fx-hud']:hideHud()
    end

    wc.nui.send('open', buildPayload(menu))

    if menu.onOpen then
        local ok, err = pcall(menu.onOpen)
        if not ok then wc.utils.error('menu.onOpen errored: ' .. tostring(err)) end
    end

    triggerMenuEvent('opened', menu.id)
end

--- Close the current menu (and all parents).
function Menu.close()
    if not state.isOpen then return end

    local closedMenu = state.current
    state.current = nil
    state.stack = {}
    state.isOpen = false
    state.anchor = nil

    wc.nui.send('close')
    wc.nui.setFocus(false, false)
    wc.input.disable()
    wc.sound.close()
    setGamePaused(false)

    if GetResourceState('fx-hud') == 'started' then
        exports['fx-hud']:showHud()
    end

    if closedMenu and closedMenu.onClose then
        local ok, err = pcall(closedMenu.onClose)
        if not ok then wc.utils.error('menu.onClose errored: ' .. tostring(err)) end
    end

    triggerMenuEvent('closed', closedMenu and closedMenu.id)
end

--- Go back one level in the navigation stack. Closes if no parent.
function Menu.back()
    if not state.isOpen then return end

    if #state.stack == 0 then
        Menu.close()
        return
    end

    local parent = table.remove(state.stack)
    state.current = parent
    wc.nui.send('open', buildPayload(parent))
    wc.sound.back()
end

--- Update the currently-open menu without closing it.
function Menu.update(patch)
    if not state.current then return end
    state.current = wc.utils.tableMerge(state.current, patch)
    wc.nui.send('update', buildPayload(state.current))
end

--- Returns true if a menu is currently open.
function Menu.isOpen() return state.isOpen end

--- Returns the id of the currently-open menu.
function Menu.currentId() return state.current and state.current.id end

--- Set cached player job data used by job/grade item requirements.
---@param job string|table
---@param grade number|nil
function Menu.setPlayerJob(job, grade)
    state.playerJob = normalizePlayerJob(job, grade)
    if state.isOpen and state.current then
        wc.nui.send('update', buildPayload(state.current))
    end
end

--- Build a client/server event menu item with the standard wc_menu action payload.
---@param opts table
function Menu.action(opts)
    opts = opts or {}
    assert(opts.id, 'wc.menu.action: opts.id is required')
    assert(opts.label, 'wc.menu.action: opts.label is required')
    assert(opts.serverEvent or opts.clientEvent or opts.onSelect, 'wc.menu.action: action target is required')
    return {
        id = opts.id,
        type = opts.type,
        label = opts.label,
        icon = opts.icon,
        image = opts.image,
        description = opts.description,
        confirm = opts.confirm,
        disabled = opts.disabled,
        disabledReason = opts.disabledReason or opts.reason or opts.lockedReason,
        requirements = opts.requirements or opts.requirement,
        requiredJob = opts.requiredJob,
        requiredGrade = opts.requiredGrade,
        job = opts.job,
        grade = opts.grade,
        rank = opts.rank,
        status = opts.status,
        rarity = opts.rarity,
        stock = opts.stock,
        owned = opts.owned,
        limit = opts.limit,
        tags = opts.tags,
        meta = opts.meta or opts.metadata,
        price = opts.price,
        value = opts.value,
        min = opts.min,
        max = opts.max,
        step = opts.step,
        serverEvent = opts.serverEvent,
        clientEvent = opts.clientEvent,
        onSelect = opts.onSelect,
        args = opts.args,
    }
end

--- Build a purchase-style quantity item. Server must validate money/items before granting anything.
---@param opts table
function Menu.purchase(opts)
    opts = opts or {}
    assert(opts.id, 'wc.menu.purchase: opts.id is required')
    assert(opts.label, 'wc.menu.purchase: opts.label is required')
    assert(opts.serverEvent, 'wc.menu.purchase: opts.serverEvent is required')
    return Menu.action({
        id = opts.id,
        type = 'quantity',
        label = opts.label,
        icon = opts.icon or 'dollar-sign',
        image = opts.image,
        description = opts.description,
        confirm = opts.confirm ~= false and (opts.confirm or 'Confirm purchase?') or false,
        price = opts.price,
        disabled = opts.disabled,
        disabledReason = opts.disabledReason or opts.reason or opts.lockedReason,
        requirements = opts.requirements or opts.requirement,
        requiredJob = opts.requiredJob,
        requiredGrade = opts.requiredGrade,
        job = opts.job,
        grade = opts.grade,
        rank = opts.rank,
        status = opts.status,
        rarity = opts.rarity,
        stock = opts.stock,
        owned = opts.owned,
        limit = opts.limit,
        tags = opts.tags,
        meta = opts.meta or opts.metadata,
        value = opts.value or opts.min or 1,
        min = opts.min or 1,
        max = opts.max or 99,
        step = opts.step or 1,
        serverEvent = opts.serverEvent,
        args = opts.args,
    })
end

-- ═══════════════════════════════════════════════════════════
--                    NUI CALLBACK ROUTING
-- ═══════════════════════════════════════════════════════════

wc.nui.registerCallback('select', function(data, cb)
    cb({ ok = true })
    if not state.current then return end
    local item = state.current.items[data.index]
    if not item or item.disabled then
        wc.sound.error()
        return
    end

    wc.sound.select()
    triggerMenuEvent('itemSelected', state.current.id, item.id)

    if item.submenu then
        if type(item.submenu) == 'function' then
            local sub = item.submenu()
            if sub then Menu.open(sub) end
        else
            Menu.open(item.submenu)
        end
    elseif item.serverEvent then
        TriggerServerEvent(item.serverEvent, buildActionPayload(state.current, item, data))
    elseif item.clientEvent then
        TriggerEvent(item.clientEvent, buildActionPayload(state.current, item, data))
    elseif item.onSelect then
        local ok, err = pcall(item.onSelect, item, data)
        if not ok then wc.utils.error('onSelect errored: ' .. tostring(err)) end
    end
end)

wc.nui.registerCallback('hover', function(data, cb)
    cb({ ok = true })
    if not state.current then return end
    local item = state.current.items[data.index]
    if not item then return end
    triggerMenuEvent('itemHovered', state.current.id, item.id)
    if item.onHover then pcall(item.onHover, item) end
end)

wc.nui.registerCallback('change', function(data, cb)
    cb({ ok = true })
    if not state.current then return end
    local item = state.current.items[data.index]
    if not item then return end
    item.value = data.value
    if item.onChange then pcall(item.onChange, data.value, item) end
end)

wc.nui.registerCallback('back', function(_, cb)
    cb({ ok = true })
    Menu.back()
end)

wc.nui.registerCallback('close', function(_, cb)
    cb({ ok = true })
    Menu.close()
end)

wc.nui.registerCallback('navigate', function(_, cb)
    cb({ ok = true })
    wc.sound.nav()
end)

wc.nui.registerCallback('tab', function(data, cb)
    cb({ ok = true })
    if not state.current then return end
    triggerMenuEvent('tab', state.current.id, data and data.index)
    if state.current.onTab then
        local ok, err = pcall(state.current.onTab, data)
        if not ok then wc.utils.error('menu.onTab errored: ' .. tostring(err)) end
    end
end)

wc.nui.registerCallback('ready', function(_, cb)
    cb({ ok = true })
    wc.utils.log('NUI ready')
end)

-- ═══════════════════════════════════════════════════════════
--                    BIND TO wc.menu
-- ═══════════════════════════════════════════════════════════

--- Update a single item by id without closing or re-opening the menu.
--- Only the fields present in `patch` are changed; everything else is preserved.
---@param id string      The item's id field
---@param patch table    Fields to update (e.g. { badge = 5, label = 'New label', disabled = true })
function Menu.updateItem(id, patch)
    if not state.current then return end
    for _, item in ipairs(state.current.items) do
        if item.id == id then
            for k, v in pairs(patch) do
                item[k] = v
            end
            wc.nui.send('update', buildPayload(state.current))
            return
        end
    end
    wc.utils.warn('wc.menu.updateItem: item not found: ' .. tostring(id))
end

--- Show a toast notification (does not require a menu to be open).
---@param text string  Message to display
---@param icon string  Font Awesome icon name (e.g. 'check', 'xmark') — optional
---@param duration number  Milliseconds to show (default 2500)
function Menu.toast(text, icon, duration)
    wc.nui.send('toast', {
        text     = tostring(text or ''),
        icon     = icon,
        duration = duration or 2500,
    })
end

wc.menu.open       = Menu.open
wc.menu.close      = Menu.close
wc.menu.back       = Menu.back
wc.menu.update     = Menu.update
wc.menu.updateItem = Menu.updateItem
wc.menu.action     = Menu.action
wc.menu.purchase   = Menu.purchase
wc.menu.isOpen     = Menu.isOpen
wc.menu.currentId  = Menu.currentId
wc.menu.setPlayerJob = Menu.setPlayerJob
wc.menu.toast      = Menu.toast

RegisterNetEvent('wc_menu:setPlayerJob', function(job, grade)
    Menu.setPlayerJob(job, grade)
end)

-- ═══════════════════════════════════════════════════════════
--                    SAFETY
-- ═══════════════════════════════════════════════════════════

-- Close menu on resource stop to avoid stuck NUI focus
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and state.isOpen then
        wc.nui.setFocus(false, false)
        setGamePaused(false)
    end
end)

-- Close menu on player death
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if state.isOpen and IsEntityDead(PlayerPedId()) then
            Menu.close()
        elseif state.isOpen and state.anchor and Config.AutoCloseDistance > 0 then
            local coords = getPlayerCoords()
            if coords and #(coords - state.anchor) > Config.AutoCloseDistance then
                Menu.close()
            end
        end
    end
end)
