fx_version 'cerulean'
games { 'gta5' }

author 'Jeesus Krisostoomus#7737'
description 'https://github.com/JeesusKrisostoomus'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
	'async',
	'mysql-async'
}