local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedPeds = {}
lib.locale()

CreateThread(function()
    for k,v in pairs(Config.BlacksmithLocations) do
        if not Config.EnableTarget then
            exports['rsg-core']:createPrompt(v.blacksmithid, v.coords, RSGCore.Shared.Keybinds[Config.Keybind], locale('cl_lang_47'), {
                type = 'client',
                event = 'rex-blacksmith:client:openblacksmith',
                args = {v.blacksmithid, v.jobaccess, v.name}
            })
        end
        if v.showblip == true then
            local PlayerBlacksmithBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(PlayerBlacksmithBlip, joaat(v.blipsprite), true)
            SetBlipScale(PlayerBlacksmithBlip, v.blipscale)
            SetBlipName(PlayerBlacksmithBlip, v.blipname)
        end
    end
end)

local function NearNPC(npcmodel, npccoords, heading)
    local spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, heading, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    SetRandomOutfitVariation(spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)
    SetPedFleeAttributes(spawnedPed, 0, false)
    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end
    return spawnedPed
end

CreateThread(function()
    for k,v in pairs(Config.BlacksmithLocations) do
        local coords = v.npccoords
        local newpoint = lib.points.new({
            coords = coords,
            heading = coords.w,
            distance = Config.DistanceSpawn,
            model = v.npcmodel,
            ped = nil,
            blacksmithid = v.blacksmithid, 
            jobaccess = v.jobaccess, 
            name = v.name
        })
        
        newpoint.onEnter = function(self)
            if not self.ped then
                lib.requestModel(self.model, 10000)
                self.ped = NearNPC(self.model, self.coords, self.heading)

                pcall(function ()
                    if Config.EnableTarget then
                        exports.ox_target:addLocalEntity(self.ped, {
                            {
                                name = 'npc_blacksmith',
                                icon = 'far fa-eye',
                                label = locale('cl_lang_47'),
                                onSelect = function()
                                    TriggerEvent('rex-blacksmith:client:openblacksmith', self.blacksmithid, self.jobaccess, self.name)
                                end,
                                distance = 2.0
                            }
                        })
                    end
                end)
            end
        end

        newpoint.onExit = function(self)
            exports.ox_target:removeEntity(self.ped, 'npc_blacksmith')
            if self.ped and DoesEntityExist(self.ped) then
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(self.ped, i, false)
                    end
                end
                DeleteEntity(self.ped)
                self.ped = nil
            end
        end

        spawnedPeds[k] = newpoint
    end
end)

-- cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(spawnedPeds) do
        exports.ox_target:removeEntity(spawnedPed, 'npc_blacksmith')
        if v.ped and DoesEntityExist(v.ped) then
            DeleteEntity(v.ped)
        end
        spawnedPeds[k] = nil
    end
end)
