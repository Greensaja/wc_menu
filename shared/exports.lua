--[[
    wc_menu exports registration.
    Primary API is the `wc` global, but also exposed as exports for compatibility.
]]

-- expose global wc as exports for resources that prefer exports pattern
exports('getWC', function() return wc end)
exports('getVersion', function() return wc.version end)
