fx_version 'cerulean'
game 'gta5'

version '1.0.0'
description 'https://github.com/Qbox-project'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'