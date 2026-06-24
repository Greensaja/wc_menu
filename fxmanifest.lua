fx_version "adamant"
game "rdr3"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'wc_menu'
author 'Green / Wild County'
description 'wc_menu - modern ornamental menu library for RedM'
version '1.0.0'


ui_page 'nui/index.html'

shared_scripts {
    'config.lua',
    'shared/shared.lua',
    'shared/exports.lua'
}

client_scripts {
    'client/sound.lua',
    'client/input.lua',
    'client/nui.lua',
    'client/main.lua',
    'client/exports.lua',
    'client/debug.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'nui/index.html',
    'nui/css/*.css',
    'nui/js/*.js',
    'nui/assets/wc/*.png',
    'nui/assets/images/*.png',
    'nui/assets/sounds/*.mp3',
    'nui/fonts/*.ttf'
}
