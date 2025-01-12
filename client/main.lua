local ESX = exports["es_extended"]:getSharedObject()

-- Configuration
local Config = {
    Price = 50,
    Locations = {
        vector3(26.5906, -1392.0261, 27.3634),
        vector3(167.1034, -1719.4704, 27.2916),
        vector3(-74.5693, 6427.8715, 29.4400),
        vector3(-699.6325, -932.7043, 17.0139)
    },
    Distance = 5.0,
    Debug = false -- Mettre à true pour activer les messages de debug
}

-- Variables locales
local isNearCarWash = false
local currentLocation = nil
local isCleaning = false

-- Fonction pour vérifier si le joueur est dans un véhicule
local function IsInVehicle()
    local ped = PlayerPedId()
    return IsPedInAnyVehicle(ped, false)
end

-- Fonction pour vérifier si le véhicule a besoin d'être lavé
local function NeedsWash()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    return GetVehicleDirtLevel(vehicle) > 0.1
end

-- Fonction pour laver le véhicule
local function WashVehicle()
    if isCleaning then return end
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle then return end
    
    -- Vérifier si le joueur a assez d'argent
    ESX.TriggerServerCallback('esx_carwash:canAfford', function(canAfford)
        if not canAfford then
            ESX.ShowNotification('~r~Vous n\'avez pas assez d\'argent')
            return
        end
        
        isCleaning = true
        
        -- Animation de lavage
        FreezeEntityPosition(vehicle, true)
        ESX.ShowNotification('~b~Lavage en cours...')
        
        -- Particules d'eau
        UseParticleFxAssetNextCall('core')
        local particles = {}
        
        for i = 0, 3 do
            local coords = GetEntityCoords(vehicle)
            particles[#particles + 1] = StartParticleFxLoopedAtCoord('ent_amb_waterfall_splash_p', coords.x, coords.y, coords.z + 1, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        end
        
        -- Timer de lavage
        Wait(5000)
        
        -- Nettoyer le véhicule
        SetVehicleDirtLevel(vehicle, 0.0)
        WashDecalsFromVehicle(vehicle, 1.0)
        
        -- Arrêter les particules
        for _, particle in ipairs(particles) do
            StopParticleFxLooped(particle, 0)
        end
        
        -- Fin du lavage
        FreezeEntityPosition(vehicle, false)
        isCleaning = false
        ESX.ShowNotification('~g~Votre véhicule est maintenant propre!')
        
    end)
end

-- Thread principal optimisé
CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        isNearCarWash = false
        
        if IsInVehicle() then
            for _, location in ipairs(Config.Locations) do
                local distance = #(coords - location)
                
                if distance < Config.Distance then
                    wait = 0
                    isNearCarWash = true
                    currentLocation = location
                    
                    if NeedsWash() then
                        ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour laver votre véhicule (~g~$' .. Config.Price .. '~s~)')
                        
                        if IsControlJustReleased(0, 38) then
                            WashVehicle()
                        end
                    else
                        ESX.ShowHelpNotification('~y~Votre véhicule est déjà propre')
                    end
                    break
                end
            end
        end
        
        Wait(wait)
    end
end)

-- Création des blips
CreateThread(function()
    for _, location in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(location)
        
        SetBlipSprite(blip, 100)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 4)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Station de lavage')
        EndTextCommandSetBlipName(blip)
    end
end) 