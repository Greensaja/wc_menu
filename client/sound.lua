--[[
    wc_menu sound module
    Sounds are handled entirely by the NUI (HTML5 Audio).
    These stubs keep the API surface intact so main.lua doesn't change.
]]

local Sound = {}

function Sound.open()    end
function Sound.close()   end
function Sound.nav()     end
function Sound.select()  end
function Sound.back()    end
function Sound.error()   end
function Sound.confirm() end
function Sound.custom() end

wc.sound = Sound

