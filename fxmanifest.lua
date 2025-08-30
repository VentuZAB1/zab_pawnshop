shared_script '@maikatiepedal/ai_module_fg-obfuscated.lua'
shared_script '@maikatiepedal/shared_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'

name 'zab_pawnshop'
description 'Modern Pawnshop System for QBox Framework'
author 'VentuZAB'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
