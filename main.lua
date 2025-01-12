local ESX = exports["es_extended"]:getSharedObject()

-- Callback pour vérifier si le joueur peut payer
ESX.RegisterServerCallback('esx_carwash:canAfford', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then 
        cb(false)
        return
    end
    
    if xPlayer.getMoney() >= 50 then
        xPlayer.removeMoney(50)
        cb(true)
    else
        cb(false)
    end
end) 