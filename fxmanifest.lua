fx_version 'cerulean'
game 'gta5'

description 'ESX Car Wash'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'config.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    '@RageUI/RageUI.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
    'RageUI'
} 