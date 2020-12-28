--[[ Trash Collection ]]
local oldPrint = print
print = function(trash)
	oldPrint('^7[^2Kyk-AntiCombatLog^7] '..trash..'^0')
end

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- esx_ambulancejob config check
Citizen.CreateThread(function()
	if GetResourceState('esx_ambulancejob') == 'started' then
		local ambulancejobConfig = LoadResourceFile('esx_ambulancejob','config.lua')
		if string.match(ambulancejobConfig, "Config.AntiCombatLog              = true") then
			print('^7[^1WARNING^7] esx_ambulancejob AntiCombatLog is interfearing with this script. Please edit esx_amublancejob config accordingly: Config.AntiCombatLog = false')
		end
	end
end)


RegisterNetEvent('Kyk-AntiCombatLog:playerStatusUpdate')
AddEventHandler('Kyk-AntiCombatLog:playerStatusUpdate', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		MySQL.Sync.execute('UPDATE users SET isDead = @isDead WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier,
			['@isDead'] = isDead
		})
	end
end)

-- Dead status callback
ESX.RegisterServerCallback('Kyk-AntiCombatLog:isPlayerDead', function (source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil then
	    local identifier = xPlayer.identifier
		MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
			  ['@identifier'] = identifier
			},function(result)
				print(result[1].isDead)
				if result[1].isDead == 1 then
					cb(true)
				else
					cb(false)
				end
			end
		)
	end
end)

-- Update Checking System
if Config.CheckForUpdates then
	local version = '1.0'
	local resourceName = "Kyk-AntiCombatLog ("..GetCurrentResourceName()..")"
	
	Citizen.CreateThread(function()
		function checkVersion(err,response, headers)
			if err == 200 then
				local data = json.decode(response)
				if version ~= data.antiCombatLog and tonumber(version) < tonumber(data.antiCombatLog) then
					print(""..resourceName.." ~r~is outdated.\nNewest Version: "..data.antiCombatLog.."\nYour Version: "..version.."\nPlease get the latest update from https://github.com/JeesusKrisostoomus/Kyk-AntiCombatLog")
				elseif tonumber(version) > tonumber(data.antiCombatLog) then
					print("Your version of "..resourceName.." seems to be higher than the current version.")
				else
					print(resourceName.. " is up to date!")
				end
			else
				print("Version Check failed! HTTP Error Code: "..err)
			end
			
			SetTimeout(3600000, checkVersionHTTPRequest) --[[ Makes the version check repeat every 1h ]]
		end
		function checkVersionHTTPRequest() --[[ Registers checkVersionHTTPRequest function ]]
			PerformHttpRequest("https://raw.githubusercontent.com/JeesusKrisostoomus/Kyk-Releases/main/versions.json", checkVersion, "GET") --[[ Sends GET http requests ]]
		end
		checkVersionHTTPRequest() --[[ Calls checkVersionHTTPRequest function ]]
	end)
end