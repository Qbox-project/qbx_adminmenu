fx_version 'cerulean'
game 'gta5'

version '1.0.0'
description 'https://github.com/Qbox-project'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    '@ox_lib/init.lua',
    'config.lua',
    '@qbx_core/import.lua'
}

modules {
    'qbx_core:core',
    'qbx_core:utils',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/commands.lua'
}

client_scripts {
    'client/main.lua',
    'client/admin.lua',
    'client/server.lua',
    'client/dev.lua',
    'client/player.lua',
    'client/vehicle.lua',
    'client/vectors.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
