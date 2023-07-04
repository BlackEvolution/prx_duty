fx_version "cerulean"
game "gta5"

version '1.0'
description 'Advanced Duty System für ESX Legacy'
author 'Proxys'

lua54 "yes"

client_scripts {
    "client/main.lua",
}

shared_scripts {
    '@es_extended/locale.lua',
    'locales.lua',
    'sh_config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	--'@oxmysql/lib/MySQL.lua', 
    's_config.lua',
    'server/main.lua',
    'server/data.lua',
	
	'server/versioncheck.lua'
}

escrow_ignore {
    'sh_config.lua',
	's_config.lua',
	'locales.lua'
}

shared_script '@es_extended/imports.lua'