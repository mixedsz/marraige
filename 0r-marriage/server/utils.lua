Core, FW = GetCore()

-- Returns the character's full name (firstname + lastname) from the active framework.
function GetCharacterName(src)
    if FW == 'esx' then
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getName()
        end
    elseif FW == 'qb' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            local info = Player.PlayerData.charinfo
            return info.firstname .. ' ' .. info.lastname
        end
    end
    -- Fallback to the FiveM native (returns online/Steam display name)
    return GetPlayerName(src)
end

-- Returns the character's persistent identifier (license for ESX, citizenid for QB).
function GetCharacterIdentifier(src)
    if FW == 'esx' then
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.identifier
        end
    elseif FW == 'qb' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    end
    return nil
end

-- Returns true if the player currently has at least one of the given item.
function HasItem(src, item)
    if Config.Inventory == 'ox' then
        local count = exports.ox_inventory:Search(src, 'count', item)
        return count ~= nil and count > 0
    elseif Config.Inventory == 'qb' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            local itemData = Player.Functions.GetItemByName(item)
            return itemData ~= nil and itemData.amount > 0
        end
    elseif Config.Inventory == 'ls' then
        local count = exports['linden_inventory']:getItemCount(src, item)
        return count ~= nil and count > 0
    else
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData ~= nil and itemData.count > 0
        end
    end
    return false
end

-- Removes `count` of the given item from the player's inventory.
function RemoveItem(src, item, count)
    count = count or 1
    if Config.Inventory == 'ox' then
        return exports.ox_inventory:RemoveItem(src, item, count)
    elseif Config.Inventory == 'qb' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            return Player.Functions.RemoveItem(item, count)
        end
    elseif Config.Inventory == 'ls' then
        exports['linden_inventory']:removeItem(src, item, count)
        return true
    else
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.removeInventoryItem(item, count)
            return true
        end
    end
    return false
end

-- Adds `count` of the given item to the player's inventory.
function AddItem(src, item, count)
    count = count or 1
    if Config.Inventory == 'ox' then
        return exports.ox_inventory:AddItem(src, item, count)
    elseif Config.Inventory == 'qb' then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            return Player.Functions.AddItem(item, count)
        end
    elseif Config.Inventory == 'ls' then
        exports['linden_inventory']:addItem(src, item, count)
        return true
    else
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            return true
        end
    end
    return false
end

-- Sends a notification to the target player via the client-side Notify helper.
function ServerNotify(src, message, ntype)
    TriggerClientEvent('0r-marriage-notify', src, message, ntype)
end

-- Searches all connected players and returns the server source of the one whose
-- persistent identifier matches, or nil if no match is found.
function FindPlayerByIdentifier(identifier)
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if GetCharacterIdentifier(pid) == identifier then
            return pid
        end
    end
    return nil
end
