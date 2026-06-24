--[[
    wc_menu client exports
    Resources can use either:
      wc.menu.open({...})                        -- preferred (global)
      exports.wc_menu:OpenMenu({...})            -- alternative (exports)
]]

exports('OpenMenu',     function(menu)  wc.menu.open(menu)        end)
exports('CloseMenu',    function()      wc.menu.close()           end)
exports('BackMenu',     function()      wc.menu.back()            end)
exports('UpdateMenu',   function(patch) wc.menu.update(patch)     end)
exports('UpdateItem',   function(id, patch) wc.menu.updateItem(id, patch) end)
exports('ActionItem',   function(opts) return wc.menu.action(opts) end)
exports('PurchaseItem', function(opts) return wc.menu.purchase(opts) end)
exports('IsMenuOpen',   function()      return wc.menu.isOpen()    end)
exports('CurrentMenuId',function()      return wc.menu.currentId() end)
exports('Toast',        function(text, icon, duration) wc.menu.toast(text, icon, duration) end)
