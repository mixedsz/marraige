shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

shared_script '@WaveShield/resource/include.lua'
fx_version 'adamant'
game 'gta5'
lua54 'yes'

ui_page 'ui/index.html'

files {
    "ui/fonts/*.ttf",
    "ui/fonts/*.otf",
    "ui/img/*.**",
    "ui/index.html",
    "ui/script.js",
    "ui/style.css",
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/**.lua'
}

client_scripts {
    'client/**.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/**.lua'
}

escrow_ignore {
    'shared/**.lua',
    'client/**.lua',
    'server/**.lua'
}
dependency '/assetpacks'
