local oldPrint = print
print = function(trash)
	oldPrint('^7[^2Kyk-AntiCombatLog^7] '..trash..'^0')
end

ESX = nil
local isDead = false
local firstSpawn = true

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler("playerSpawned", function()
	if firstSpawn then
		if Config.Debug then
			print('Player spawned for the first time')
		end
		ESX.TriggerServerCallback('Kyk-AntiCombatLog:isPlayerDead', function(status)
			if Config.Debug then
				print('Is player dead on first spawn: '..tostring(status))
			end
			if status and ESX.IsPlayerLoaded() then
				Wait(2000) -- Possibly fixed respawn bug
				SetEntityHealth(GetPlayerPed(-1),0)
				TriggerServerEvent('Kyk-AntiCombatLog:playerStatusUpdate',true)
				isDead = true
				TriggerEvent("chat:addMessage", {
					color = {255, 255, 255},
					multiline = true,
					args = { '^1System^7', "You have been re-killed because you attempted to combatlog." } -- Edit the combatlog message here.
				})
			end
		end)
		firstSpawn = false
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	TriggerServerEvent('Kyk-AntiCombatLog:playerStatusUpdate',true)
	isDead = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if isDead and GetEntityHealth(GetPlayerPed(-1)) > 0 then
			TriggerServerEvent('Kyk-AntiCombatLog:playerStatusUpdate',false)
			isDead = false
			Citizen.Wait(50)
		end
	end
end)