CreateThread(function()
    blip = AddBlipForCoord(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z)
    SetBlipSprite(blip, 621)
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Priest')
    EndTextCommandSetBlipName(blip)
end)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = player
                closestDistance = distance
                closestPed = targetPed
            end
        end
    end

    return closestPlayer, closestDistance, closestPed
end

function Notify(message, type)
    if Config.Framework == "qb" then
        if type == 'inform' then type = 'primary' end
        TriggerEvent('QBCore:Notify', message, type, 5000)
    else
        Core.ShowNotification(message)
    end
end RegisterNetEvent('0r-marriage-notify', Notify)


function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end