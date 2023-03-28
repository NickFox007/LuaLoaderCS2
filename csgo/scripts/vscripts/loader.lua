LOADER_VERSION = "1.0"

LOADER_CURRENTSCRIPTINFO = {}

local scripts = {"simplead"}
local loadedscripts = {}
local loadedscriptsstatus = {}
local loadedscriptsinfo = {}
local loadedscriptscount = 0

function LoaderPrint(text, commandName)
	if commandName == nil then commandName = "" end
	PrintLinkedConsoleMessage("[LuaLoader] " .. text .. "\n", commandName)
end

function LOADER_SCRIPTINFODEFAULT(script)		
	
	LOADER_CURRENTSCRIPTINFO['name'] = script
	LOADER_CURRENTSCRIPTINFO['desc'] = "No desc"
	LOADER_CURRENTSCRIPTINFO['version'] = "1"
	LOADER_CURRENTSCRIPTINFO['author'] = "No author"
end

function LOADER_SETSCRIPTINFO(name, desc, version, author)		
	
	LOADER_CURRENTSCRIPTINFO['name'] = name
	LOADER_CURRENTSCRIPTINFO['desc'] = desc
	LOADER_CURRENTSCRIPTINFO['version'] = version
	LOADER_CURRENTSCRIPTINFO['author'] = author	
end


function LoaderCheckExist(script)
	if loadedscriptscount > 0 then
		for i = 1, loadedscriptscount do
			if loadedscripts[i] == script then
				return i
			end
		end
	end
	return false
end

function AppendScriptToList(script)
	loadedscriptscount = loadedscriptscount + 1
	loadedscripts[loadedscriptscount] = script

	local infotable = {}
		
	for k, v in pairs(LOADER_CURRENTSCRIPTINFO) do
		infotable[k] = v
		
	end	
	
	infotable['script'] = script
	loadedscriptsinfo[loadedscriptscount] = infotable

	return loadedscriptscount
end

function CallRequire(script, customname)

	LOADER_SCRIPTINFODEFAULT(script)

	require(script)
	
	if(customname ~= "") then LOADER_CURRENTSCRIPTINFO['name'] = customname end
	
	for k, v in pairs(LOADER_CURRENTSCRIPTINFO) do
		if v == nil then LOADER_CURRENTSCRIPTINFO[k] = "No info" end
	end
	
end

function LoadScriptAndList(script, customname)

	if script == nil then
		LoaderPrint("Empty script name specified...")
	else

		local result = xpcall(CallRequire, function(e) print(debug.traceback()) return e end, script, customname)
		local scriptindex = LoaderCheckExist(script)
		if result then

			if not scriptindex then

				scriptindex = AppendScriptToList(script)
				LoaderPrint("Script ".. GetScriptFullInfo(scriptindex) .." successfully loaded")

			else
				LoaderPrint("Script ".. GetScriptFullInfo(scriptindex) .." successfully reloaded")
			end

			loadedscriptsstatus[scriptindex] = true

		else
			LoaderPrint("Couldnt load script '".. script .."' ...")

			if not scriptindex then
				scriptindex = AppendScriptToList(script)
			end
			loadedscriptsstatus[scriptindex] = false

		end
	end
end


function LoadScriptsConfig()
	local kv = LoadKeyValues("scripts/configs/lualoader.ini")
	
	if kv ~= nil then
		
		if kv['Configs'].autoload == 1 then
			for k, v in pairs(kv['Scripts']) do
				LoadScriptAndList(k, v)
			end
		else
			LoaderPrint("Scripts' autoload was disabled in config file (scripts/configs/lualoader.ini)")
		end
		return true
	else
		LoaderPrint("Couldn't load config file (scripts/configs/lualoader.ini). LuaLoader wasn't started.")
		return false
	end

end




function CheckIfServer()
	local res = IsClient() or Convars:GetCommandClient() == nil
	--if not res then LoaderPrint("This command could be used only from server console") end
	return res
end

function LoadCmd(commandName, arg1)
	if CheckIfServer() then
		if arg1~=nil then
			LoadScriptAndList(arg1)
		else
		LoaderPrint("Specify script's name!")
		end
	end
end

function ReLoadCmd(commandName, arg1)
	if CheckIfServer() then
		if arg1~=nil then
			arg1 = tonumber(arg1)
			if arg1 ~=nil then
				if arg1 > 0 and arg1 <= loadedscriptscount then
					LoadScriptAndList(loadedscripts[arg1])
				else
					LoaderPrint("Script not found. Specify correct script's id!")
				end
			else
				LoaderPrint("Invalid id specified. Specify correct script's id!")
			end
		else
			LoaderPrint("Script's id isn't specified. Specify script's id!")
		end
	end
end

function GetScriptFullInfo(index)
	return "'" .. loadedscriptsinfo[index]['name'] .. "' (" .. loadedscriptsinfo[index]['author'] .. ") v" .. loadedscriptsinfo[index]['version'] .. " [" .. loadedscriptsinfo[index]['desc'] .. "]"
end

function ListCmd(commandName)
	if CheckIfServer() then
		LoaderPrint("=========================================================================================")
		LoaderPrint("There are " .. loadedscriptscount .. " scripts:")
		for k, v in pairs(loadedscripts) do
			if loadedscriptsstatus[k] then LoaderPrint("[" .. k .. "] " .. GetScriptFullInfo(k))
			else LoaderPrint("[" .. k .. "]\t" .. v .. " [FAILED]")
			end
		end
		LoaderPrint("=========================================================================================")
	end
end

LoaderPrint("Loader version " .. LOADER_VERSION .. " by NF")

if LoadScriptsConfig() then

	Convars:RegisterCommand("lua_loadscript", LoadCmd, "Load lua-script", 0x1000)
	Convars:RegisterCommand("lua_reloadscript", ReLoadCmd, "Reload lua-script by its id", 0x1000)
	Convars:RegisterCommand("lua_listscripts", ListCmd, "List loaded lua-scripts", 0x1000)
end