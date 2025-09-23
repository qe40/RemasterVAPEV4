repeat task.wait() until game:IsLoaded()
if shared.NewVape then shared.NewVape:Uninject() end

if identifyexecutor then
	if table.find({'Argon'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local NewVape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		NewVape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/qe40/RemasterVAPEV4/'..readfile('ReVape/profiles/commit.txt')..'/'..select(1, path:gsub('ReVape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape remaster updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	NewVape.Init = nil
	NewVape:Load()
	task.spawn(function()
		repeat
			NewVape:Save()
			task.wait(10)
		until not NewVape.Loaded
	end)

	local teleportedServers
	NewVape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.ReVapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.Revapereload = true
				if shared.ReVapeDeveloper then
					loadstring(readfile('ReVape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/qe40/RemasterVAPEV4/'..readfile('ReVape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.ReVapeDeveloper then
				teleportScript = 'shared.ReVapeDeveloper = true\n'..teleportScript
			end
			if shared.ReVapeCustomProfile then
				teleportScript = 'shared.ReVapeCustomProfile = "'..shared.ReVapeCustomProfile..'"\n'..teleportScript
			end
			NewVape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.Revapereload then
		if not NewVape.Categories then return end
		if NewVape.Categories.Main.Options['GUI bind indicator'].Enabled then
			NewVape:CreateNotification('Finished Loading', NewVape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(NewVape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('ReVape/profiles/gui.txt') then
	writefile('ReVape/profiles/gui.txt', 'new')
end
local gui = readfile('ReVape/profiles/gui.txt')

if not isfolder('ReVape/assets/'..gui) then
	makefolder('ReVape/assets/'..gui)
end
NewVape = loadstring(downloadFile('ReVape/guis/'..gui..'.lua'), 'gui')()
shared.NewVape = NewVape

if not shared.ReVapeIndependent then
	loadstring(downloadFile('ReVape/games/universal.lua'), 'universal')()
	print("downloaded univerisal")
	if isfile('ReVape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('ReVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
		print("found gameplaceid")
	else
		warn("couldnt find it ")
		if not shared.ReVapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/qe40/RemasterVAPEV4/'..readfile('ReVape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('ReVape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			else
							print("404 error"..res)

			end
		end
	end
	finishLoading()
else
	NewVape.Init = finishLoading
	return NewVape
end


print("Sup lil nigga")
