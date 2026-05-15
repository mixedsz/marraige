-- pendingData[proposerSrc] = targetSrc
-- Stores the pair from the moment the check passes until the ceremony is saved to DB.
local pendingData = {}

-- ─────────────────────────────────────────────
--  Database initialisation
-- ─────────────────────────────────────────────

CreateThread(function()
    MySQL.execute([[
        CREATE TABLE IF NOT EXISTS `0r_marriage` (
            `id`       INT(11)       NOT NULL AUTO_INCREMENT,
            `player1`  VARCHAR(60)   NOT NULL,
            `player2`  VARCHAR(60)   NOT NULL,
            `name1`    VARCHAR(100)  DEFAULT NULL,
            `name2`    VARCHAR(100)  DEFAULT NULL,
            `date`     VARCHAR(50)   DEFAULT NULL,
            `day`      VARCHAR(20)   DEFAULT NULL,
            `clock`    VARCHAR(10)   DEFAULT NULL,
            `location` VARCHAR(150)  DEFAULT NULL,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
end)

-- ─────────────────────────────────────────────
--  Player login – restore ring menu if married
-- ─────────────────────────────────────────────

local function LoadPlayerMarriage(src, identifier)
    if not identifier then return end

    local result = MySQL.query.await(
        'SELECT * FROM `0r_marriage` WHERE `player1` = ? OR `player2` = ?',
        { identifier, identifier }
    )
    if not result or #result == 0 then return end

    local marriage     = result[1]
    local isPlayer1    = (marriage.player1 == identifier)
    local partnerIdent = isPlayer1 and marriage.player2 or marriage.player1
    local partnerName  = isPlayer1 and marriage.name2   or marriage.name1

    -- Prefer the live server source; fall back to the stored name if offline.
    local partnerSrc = FindPlayerByIdentifier(partnerIdent)
    TriggerClientEvent('0r-marriage-open-ring-menu', src, partnerSrc or 0, partnerName or partnerIdent)
end

-- ESX
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    Wait(5000)
    LoadPlayerMarriage(playerId, xPlayer.identifier)
end)

-- QB-Core
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Wait(5000)
    LoadPlayerMarriage(Player.PlayerData.source, Player.PlayerData.citizenid)
end)

-- ─────────────────────────────────────────────
--  Step 1 – Proposer talks to the priest
--  Client → Server: nearest player's server ID
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-check-for-marry', function(targetSrc)
    local src = source

    -- Must have the propose item in hand
    if not HasItem(src, Config.ProposeItem) then
        ServerNotify(src, Locs.noring, 'error')
        return
    end

    local srcIdent    = GetCharacterIdentifier(src)
    local targetIdent = GetCharacterIdentifier(targetSrc)
    if not srcIdent or not targetIdent then return end

    -- Neither party may already be married
    local r1 = MySQL.query.await(
        'SELECT id FROM `0r_marriage` WHERE `player1` = ? OR `player2` = ?',
        { srcIdent, srcIdent }
    )
    if r1 and #r1 > 0 then
        ServerNotify(src, Locs.alreadymarried, 'error')
        return
    end

    local r2 = MySQL.query.await(
        'SELECT id FROM `0r_marriage` WHERE `player1` = ? OR `player2` = ?',
        { targetIdent, targetIdent }
    )
    if r2 and #r2 > 0 then
        ServerNotify(src, Locs.alreadymarried, 'error')
        return
    end

    -- Consume the proposal item and begin the sequence
    RemoveItem(src, Config.ProposeItem, 1)
    pendingData[src] = targetSrc

    -- Tell the proposer to play the kneeling animation
    TriggerClientEvent('0r-marriage-propose', src, src)
end)

-- ─────────────────────────────────────────────
--  Step 2 – Proposer has played the animation;
--  forward the proposal UI to the target
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-propose-her', function(targetSrc, proposerSrc)
    local src          = source
    local proposerName = GetCharacterName(src)

    TriggerClientEvent('0r-marriage-show-menu', targetSrc, 'propose', src, proposerName)
end)

-- ─────────────────────────────────────────────
--  Step 3 – Target accepts or rejects
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-make-action', function(action, proposerSrc)
    local src    = source -- target / accepter
    local target = src

    if action == 'yes' then
        -- Celebration animations on both sides
        TriggerClientEvent('0r-marriage-yes',  proposerSrc)
        TriggerClientEvent('0r-marriage-yes2', target)

        -- Give the animations time to play before starting the ceremony
        Citizen.SetTimeout(6000, function()
            local proposerName = GetCharacterName(proposerSrc)
            local targetName   = GetCharacterName(target)
            local names        = { proposer = proposerName, target = targetName }

            -- me = true  → proposer will trigger the DB save after the ceremony
            -- me = false → target just watches
            TriggerClientEvent('0r-marriage-marry-c', proposerSrc, true,  names)
            TriggerClientEvent('0r-marriage-marry-c', target,      false, names)
        end)
    else
        -- Rejection animations
        TriggerClientEvent('0r-marriage-no',  proposerSrc)
        TriggerClientEvent('0r-marriage-no2', target)
        pendingData[proposerSrc] = nil
    end
end)

-- ─────────────────────────────────────────────
--  Step 4 – Ceremony complete; save to database
--  Only the proposer (me = true) fires this event
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-check-for-marry-s', function(location)
    local src    = source
    local target = pendingData[src]
    if not target then return end
    pendingData[src] = nil

    local srcIdent    = GetCharacterIdentifier(src)
    local targetIdent = GetCharacterIdentifier(target)
    if not srcIdent or not targetIdent then return end

    local srcName    = GetCharacterName(src)
    local targetName = GetCharacterName(target)

    local date  = os.date('%d-%m-%Y')
    local day   = os.date('%A')
    local clock = os.date('%H:%M')

    MySQL.execute.await(
        'INSERT INTO `0r_marriage` (`player1`,`player2`,`name1`,`name2`,`date`,`day`,`clock`,`location`) VALUES (?,?,?,?,?,?,?,?)',
        { srcIdent, targetIdent, srcName, targetName, date, day, clock, location }
    )

    -- Give both players their certificate and engagement ring items
    AddItem(src,    Config.CertificateItem, 1)
    AddItem(target, Config.CertificateItem, 1)
    AddItem(src,    Config.RingItem, 1)
    AddItem(target, Config.RingItem, 1)

    local certData = {
        groom  = srcName,
        bride  = targetName,
        date   = date,
        day    = day,
        clock  = clock,
        street = location,
        priest = Config.PriestName,
    }

    -- Display the marriage certificate UI to both players
    TriggerClientEvent('0r-marriage-show-menu', src,    'certificate', certData, '')
    TriggerClientEvent('0r-marriage-show-menu', target, 'certificate', certData, '')

    -- Open the partner-interaction ring menu for both players
    Citizen.SetTimeout(3500, function()
        TriggerClientEvent('0r-marriage-open-ring-menu', src,    target, targetName)
        TriggerClientEvent('0r-marriage-open-ring-menu', target, src,    srcName)
    end)
end)

-- ─────────────────────────────────────────────
--  Divorce – step 1: requester asks, target confirms
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-divorce-req', function(targetSrc)
    local src = source

    local srcIdent    = GetCharacterIdentifier(src)
    local targetIdent = GetCharacterIdentifier(targetSrc)
    if not srcIdent or not targetIdent then return end

    local result = MySQL.query.await(
        'SELECT id FROM `0r_marriage` WHERE (`player1` = ? AND `player2` = ?) OR (`player1` = ? AND `player2` = ?)',
        { srcIdent, targetIdent, targetIdent, srcIdent }
    )
    if not result or #result == 0 then
        ServerNotify(src, Locs.notfiance, 'error')
        return
    end

    -- Ask the target to confirm the divorce dialog
    TriggerClientEvent('0r-marriage-divorce-req-c', targetSrc, src, targetSrc)
end)

-- ─────────────────────────────────────────────
--  Divorce – step 2: target has confirmed
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-divorce', function(requesterId, confirmerId)
    local src = source
    -- Validate that the source matches the confirmer passed by the client
    if src ~= confirmerId then return end

    local requesterIdent = GetCharacterIdentifier(requesterId)
    local confirmerIdent = GetCharacterIdentifier(confirmerId)
    if not requesterIdent or not confirmerIdent then return end

    local rows = MySQL.execute.await(
        'DELETE FROM `0r_marriage` WHERE (`player1` = ? AND `player2` = ?) OR (`player1` = ? AND `player2` = ?)',
        { requesterIdent, confirmerIdent, confirmerIdent, requesterIdent }
    )
    if rows and rows > 0 then
        ServerNotify(requesterId, Locs.youaredivorced, 'error')
        ServerNotify(confirmerId, Locs.youaredivorced, 'error')
        TriggerClientEvent('0r-marriage-close-hud', requesterId)
        TriggerClientEvent('0r-marriage-close-hud', confirmerId)
    end
end)

-- ─────────────────────────────────────────────
--  Hug – request and accept/reject
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-hug-request-s', function(targetId, requesterId)
    local src = source  -- always trust source, not the client-supplied requesterId
    TriggerClientEvent('0r-marriage-hug-request-c', targetId, src)
end)

RegisterNetEvent('0r-marriage-hug-action', function(action, requester)
    local src = source -- accepter / rejecter

    if action == 'accept' then
        -- Requester plays their own hug anim
        TriggerClientEvent('0r-marriage-hug-acceptme',    requester)
        -- Accepter positions themselves in front of the requester and plays anim
        TriggerClientEvent('0r-marriage-hug-acceptother', src, requester)
    else
        TriggerClientEvent('0r-marriage-hug-rejectme',    src)
        TriggerClientEvent('0r-marriage-hug-rejectother', requester)
    end
end)

-- ─────────────────────────────────────────────
--  Live map – send partner's current coords
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-update-blip', function(partnerId)
    local src = source

    if not partnerId or partnerId == 0 then return end

    local partnerPed = GetPlayerPed(partnerId)
    if not partnerPed or partnerPed == 0 then return end

    local coords      = GetEntityCoords(partnerPed)
    local partnerName = GetCharacterName(partnerId)

    TriggerClientEvent('0r-marriage-update-blip-render', src, {
        coords = { x = coords.x, y = coords.y, z = coords.z },
        name   = partnerName,
    })
end)

-- ─────────────────────────────────────────────
--  HUD – periodic partner info update
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage-hud', function()
    local src = source

    local srcIdent = GetCharacterIdentifier(src)
    if not srcIdent then
        TriggerClientEvent('0r-marriage-close-hud', src)
        return
    end

    local result = MySQL.query.await(
        'SELECT * FROM `0r_marriage` WHERE `player1` = ? OR `player2` = ?',
        { srcIdent, srcIdent }
    )
    if not result or #result == 0 then
        TriggerClientEvent('0r-marriage-close-hud', src)
        return
    end

    local marriage     = result[1]
    local isPlayer1    = (marriage.player1 == srcIdent)
    local partnerIdent = isPlayer1 and marriage.player2 or marriage.player1
    local storedName   = isPlayer1 and marriage.name2   or marriage.name1

    -- Prefer live name if partner is online; use stored name otherwise
    local partnerSrc  = FindPlayerByIdentifier(partnerIdent)
    local partnerName = partnerSrc and GetCharacterName(partnerSrc) or storedName

    if partnerSrc then
        TriggerClientEvent('0r-marriage-update-hud', src, partnerName, marriage.date)
    else
        ServerNotify(src, Locs.partnerOffline, 'error')
        TriggerClientEvent('0r-marriage-close-hud', src)
    end
end)

-- ─────────────────────────────────────────────
--  ERP – synced GTA animations between two players
-- ─────────────────────────────────────────────

RegisterNetEvent('0r-marriage:requestSynced', function(targetId, animId)
    local src          = source
    local requesterName = GetCharacterName(src)
    TriggerClientEvent('0r-marriage:syncRequest', targetId, src, animId, requesterName)
end)

RegisterNetEvent('0r-marriage:syncAccepted', function(requesterId, animId)
    local src = source -- accepter

    -- Requester: face the accepter (serverid = accepter), play 'Requester' role
    TriggerClientEvent('0r-marriage:playSynced', requesterId, src,         animId, 'Requester')
    -- Accepter: face the requester (serverid = requester), play 'Accepter' role
    TriggerClientEvent('0r-marriage:playSynced', src,         requesterId, animId, 'Accepter')
end)

-- ─────────────────────────────────────────────
--  AddOn emotes – synced custom animations
-- ─────────────────────────────────────────────

RegisterNetEvent('ServerEmoteRequest', function(targetId, emoteId)
    local src = source
    TriggerClientEvent('ClientEmoteRequestReceive', targetId, emoteId, 'addon', src)
end)

RegisterNetEvent('ServerEmoteCancel', function(targetId)
    local src = source
    TriggerClientEvent('SyncCancelEmote', targetId, src)
end)

RegisterNetEvent('ServerValidEmote', function(targetId, emoteId, emoteData)
    local src = source
    -- Target plays their half of the animation
    TriggerClientEvent('SyncPlayEmote', targetId, emoteData, src)
    -- Source plays the other half, positioned relative to the target
    TriggerClientEvent('SyncPlayEmoteSource', src, emoteId, targetId)
end)

-- ─────────────────────────────────────────────
--  Engagement ring item use → open ring menu
--  This is the primary way married players access
--  the hug / live-map / HUD / ERP options.
-- ─────────────────────────────────────────────

local function OnRingItemUsed(src)
    local srcIdent = GetCharacterIdentifier(src)
    if not srcIdent then return end

    local result = MySQL.query.await(
        'SELECT * FROM `0r_marriage` WHERE `player1` = ? OR `player2` = ?',
        { srcIdent, srcIdent }
    )
    if not result or #result == 0 then
        ServerNotify(src, Locs.youaredivorced, 'error')
        return
    end

    local marriage     = result[1]
    local isPlayer1    = (marriage.player1 == srcIdent)
    local partnerIdent = isPlayer1 and marriage.player2 or marriage.player1
    local storedName   = isPlayer1 and marriage.name2   or marriage.name1

    local partnerSrc  = FindPlayerByIdentifier(partnerIdent)
    TriggerClientEvent('0r-marriage-open-ring-menu', src, partnerSrc or 0, storedName or partnerIdent)
end

if Config.Inventory == 'ox' then
    exports.ox_inventory:registerHook('useItem', function(payload)
        if payload.item.name == Config.RingItem then
            CreateThread(function()
                OnRingItemUsed(payload.source)
            end)
        end
    end, { itemFilter = { [Config.RingItem] = true } })
elseif Config.Inventory == 'qb' then
    Core.Functions.CreateUseableItem(Config.RingItem, function(src)
        CreateThread(function() OnRingItemUsed(src) end)
    end)
else
    -- ESX (and ls-inventory which proxies through ESX usable items)
    Core.RegisterUsableItem(Config.RingItem, function(src)
        CreateThread(function() OnRingItemUsed(src) end)
    end)
end
