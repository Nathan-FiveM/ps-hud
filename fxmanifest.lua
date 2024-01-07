fx_version 'cerulean'
game 'gta5'

description 'ps-hud'
version '2.1.0'

shared_scripts {
	'@ox_lib/init.lua',
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
	'config.lua',
	'uiconfig.lua'
}

client_scripts {
	'client.lua',
	'HRSGears.lua'
}
server_script 'server.lua'
lua54 'yes'
use_fxv2_oal 'yes'

ui_page 'html/index.html'

files {
	'html/*',
}
