# LuaLoaderCS2
LuaLoader for simple lua-scripts loading

Example script using this loader is on path scripts/vscripts/example.lua

# Commands

lua_loadscript SCRIPT_NAME - loads script from scripts/vscripts by its name

lua_listscripts - list all scripts loaded through LuaLoader

lua_reloadscript SCRIPT_ID -  reload script by its ID from lua_listscripts

# Installing

1) Download this repository
2) Upload to server
3) Add to "cfg/server.cfg" next command: exec lualoader
