--[[
    wc_menu shared utilities
    Defines the `wc` global namespace and helper functions.
]]

-- ═══════════════════════════════════════════════════════════
--                    wc GLOBAL NAMESPACE
-- ═══════════════════════════════════════════════════════════

wc = wc or {}
wc.menu = wc.menu or {}
wc.utils = wc.utils or {}
wc.version = '1.0.0'

-- ═══════════════════════════════════════════════════════════
--                    LOGGING
-- ═══════════════════════════════════════════════════════════

function wc.utils.log(...)
    if Config and Config.Debug then
        print('[wc_menu]', ...)
    end
end

function wc.utils.warn(...)
    print('^3[wc_menu WARN]^7', ...)
end

function wc.utils.error(...)
    print('^1[wc_menu ERROR]^7', ...)
end

-- ═══════════════════════════════════════════════════════════
--                    TABLE HELPERS
-- ═══════════════════════════════════════════════════════════

function wc.utils.tableCount(t)
    if type(t) ~= 'table' then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

function wc.utils.tableDeepCopy(t, seen)
    if type(t) ~= 'table' then return t end
    seen = seen or {}
    if seen[t] then return seen[t] end
    local copy = {}
    seen[t] = copy
    for k, v in pairs(t) do
        copy[wc.utils.tableDeepCopy(k, seen)] = wc.utils.tableDeepCopy(v, seen)
    end
    return copy
end

function wc.utils.tableMerge(a, b)
    local out = wc.utils.tableDeepCopy(a)
    for k, v in pairs(b or {}) do
        if type(v) == 'table' and type(out[k]) == 'table' then
            out[k] = wc.utils.tableMerge(out[k], v)
        else
            out[k] = v
        end
    end
    return out
end

function wc.utils.tableContains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--                    STRING HELPERS
-- ═══════════════════════════════════════════════════════════

function wc.utils.generateId(prefix)
    prefix = prefix or 'wc'
    return ('%s_%d_%d'):format(prefix, GetGameTimer and GetGameTimer() or os.time(), math.random(1000, 9999))
end

function wc.utils.truncate(s, n)
    if type(s) ~= 'string' or #s <= n then return s end
    return s:sub(1, n - 1) .. '…'
end

-- ═══════════════════════════════════════════════════════════
--                    PRICE FORMATTING
-- ═══════════════════════════════════════════════════════════

--[[
    Accepts any of:
      5                              → { { money = 5 } }
      { money = 10 }                 → { { money = 10 } }
      { money = 10, gold = 1 }       → { { money = 10 }, { gold = 1 } }
      { { item = 'pelt', quantity = 2 }, { money = 5 } }
    Returns a normalized array of price entries.
]]
function wc.utils.formatPrice(price)
    if not price then return { { money = 0 } } end
    if type(price) ~= 'table' then return { { money = price } } end

    local result = {}
    for key, value in pairs(price) do
        if type(key) == 'string' then
            if key == 'money' or key == 'gold' or key == 'rol' then
                result[#result + 1] = { [key] = value }
            elseif key == 'item' then
                result[#result + 1] = {
                    item = value,
                    quantity = price.quantity or 1,
                    label = price.label
                }
                break  -- the whole table is a single item entry
            end
        elseif type(value) == 'table' then
            for _, entry in ipairs(wc.utils.formatPrice(value)) do
                result[#result + 1] = entry
            end
        elseif type(value) == 'number' then
            result[#result + 1] = { money = value }
        end
    end

    if #result == 0 then result = { { money = 0 } } end
    return result
end

function wc.utils.priceToString(price)
    local parts = {}
    for _, entry in ipairs(wc.utils.formatPrice(price)) do
        if entry.money then
            parts[#parts + 1] = ('$%s'):format(entry.money)
        elseif entry.gold then
            parts[#parts + 1] = ('%s GOLD'):format(entry.gold)
        elseif entry.rol then
            parts[#parts + 1] = ('%s ROL'):format(entry.rol)
        elseif entry.item then
            parts[#parts + 1] = ('%dx %s'):format(entry.quantity or 1, entry.label or entry.item)
        end
    end
    return table.concat(parts, ' + ')
end

function wc.utils.isPriceFree(price)
    local formatted = wc.utils.formatPrice(price)
    if #formatted ~= 1 then return false end
    return formatted[1].money == 0
end

-- ═══════════════════════════════════════════════════════════
--                    VALIDATION
-- ═══════════════════════════════════════════════════════════

local VALID_ITEM_TYPES = {
    button = true, submenu = true, checkbox = true,
    slider = true, quantity = true, input = true,
    select = true, divider = true, label = true,
}

function wc.utils.validateItemType(itemType)
    if not itemType then return 'button' end
    if not VALID_ITEM_TYPES[itemType] then
        wc.utils.warn(('Invalid item type "%s", falling back to "button"'):format(tostring(itemType)))
        return 'button'
    end
    return itemType
end
