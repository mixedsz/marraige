Core, FW = GetCore()
local Proposer = 0
local spawnedProp = {}
local ringid = 0
local livemap = false
local live_blip = nil
local cam
local hud = false
local menuped
local letter = 1
local targetPlayerId = 0

CreateThread(function()
    local pedModel = GetHashKey(Config.MarriagePed)
    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Wait(0)
    end    
    menuped = CreatePed(0, pedModel, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z-1, Config.PedCoords.w, false, false)
    FreezeEntityPosition(menuped, true)
	SetEntityInvincible(menuped, true)
	SetBlockingOfNonTemporaryEvents(menuped, true)
        
    lib.registerContext({
        id = '0r_marriage',
        title = Locs.priest,
        options = {
            {
                title = Locs.marriage,
                description = Locs.marriageClick,
                onSelect = function()
                    TriggerEvent('0r-marriage-marry')
                end
            },
            {
                title = Locs.divorce,
                description = Locs.divorceClick,
                onSelect = function()
                    TryDivorce()
                end
            }
        }
    })

    SendNUIMessage({
        action = 'lang',
        lang = Locs
    })

    if Config.InteractType == 'drawtext' then
        while true do 
            local ms = 1000
            local ped = PlayerPedId()
            local pc = GetEntityCoords(ped)
            local dist = #(pc - vector3(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z))

            if dist < 2.0 then
                ms = 0 
                DrawText3D(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z+.9, Locs.Draw)
                if IsControlJustPressed(0, 38) then
                    lib.showContext('0r_marriage')
                end
            end
            Wait(ms)
        end
    elseif Config.InteractType == 'qb-target' then
        exports['qb-target']:AddTargetEntity(menuped, {
            options = {
                {
                    label = Locs.Target,
                    icon = 'fas fa-church',
                    action = function()
                        lib.showContext('0r_marriage')
                    end
                }
            },
            distance = 2.0
        })
    elseif Config.InteractType == 'ox_target' then
        exports.ox_target:addLocalEntity(menuped, {
			{
				name = '0r_marriage',
				onSelect = function()
                    lib.showContext('0r_marriage')
				end,
				icon = 'fas fa-church',
				label = Locs.Target,
                distance = 2.0
			}
		})
    end
end)

RegisterNetEvent('0r-marriage-open-ring-menu', function(id, name)
    ringid = id
    lib.registerContext({
        id = '0r_marriage_ring_menu',
        title = name,
        options = {
            {
                title = Locs.ShowBlip,
                description = Locs.BlipClick,
                onSelect = function()
                    livemap = not livemap
                    if livemap then
                        RemoveBlip(live_blip)
                        live_blip = nil
                        LiveMap(ringid)
                    else
                        RemoveBlip(live_blip)
                        live_blip = nil
                    end
                end
            },
            {
                title = Locs.hug,
                description = Locs.hugclick,
                onSelect = function()
                    TriggerEvent('0r-marriage-hug-request', ringid)
                end
            },
            {
                title = Locs.hud,
                description = Locs.hudclick,
                onSelect = function()
                    hud = not hud

                    SendNUIMessage({
                        action = 'hudstate',
                        state = hud
                    })
                end
            },
            {
                title = Locs.erp,
                description = Locs.erpclick,
                onSelect = function()
                    TriggerEvent('0r-marriage:openErpMenu')
                end
            },
        }
    })
    lib.showContext('0r_marriage_ring_menu')
end)

RegisterNetEvent('0r-marriage-hug-request', function(id)
    local closestplayer, distance, xx = GetClosestPlayer()
    if xx == GetPlayerPed(GetPlayerFromServerId(id)) then
        if distance <= 2.0 then
            local playerPed = PlayerPedId()
            local serverId = GetPlayerServerId(PlayerId())
            TriggerServerEvent('0r-marriage-hug-request-s', id, serverId)
        end
    else
        Notify(Locs.notfiance, 'error')
    end
end)

RegisterNetEvent('0r-marriage-hug-request-c', function(other)
    Notify(Locs.request, 'inform')
    CreateThread(function()
        while true do 
            Wait(0)
            if IsControlJustPressed(1, 246) then 
                TriggerServerEvent('0r-marriage-hug-action', 'accept', other)
                break
            end
    
            if IsControlJustPressed(1, 249) then
                TriggerServerEvent('0r-marriage-hug-action', 'reject', other)
                break
            end
        end
    end)
end)

RegisterNetEvent('0r-marriage-marry', function()
    local closestplayer, distance = GetClosestPlayer()
    if closestplayer > 0 then
        if distance <= 2.0 then
            TriggerServerEvent('0r-marriage-check-for-marry', GetPlayerServerId(closestplayer))
        else
            Notify(Locs.noone, 'error')
        end
    else
        Notify(Locs.noone, 'error')
    end
end)

RegisterNUICallback('NextLetter', function()
    letter += 1
    Wait(3500)
    if letter == 2 then
        SendNUIMessage({
            action = 'priest',
            letter = Locs.Priest2
        })
    elseif letter == 3 then
        SendNUIMessage({
            action = 'priest',
            letter = Locs.Priest3
        })
    else
        letter = 1
        SendNUIMessage({
            action = 'openpriest',
            state = false
        })
    end
end)

RegisterNetEvent('0r-marriage-marry-c', function(me, names)
    local me2 = me
    CamCreate(Config.PedCoords)
    FreezeEntityPosition(PlayerPedId(), true)
    local animDict = 'cellphone@'
    local animName = 'cellphone_text_read_base'
    local propPl1, propPl2, propPl3, propPl4, propPl5, propPl6 = table.unpack({ 0.15, 0.03, -0.02, 0.0, 0.0, 5.0 })

    addPropToPlayer('v_ilev_mp_bedsidebook', 6286, propPl1, propPl2, propPl3, propPl4, propPl5, propPl6, menuped)
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(10) end
    TaskPlayAnim(menuped, animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    PlayPedAmbientSpeechNative(menuped, 'GENERIC_THANKS', 'SPEECH_PARAMS_FORCE')
    SendNUIMessage({
        action = 'openpriest',
        state = true
    })
    Wait(1500)
    SendNUIMessage({
        action = 'priest',
        letter = Locs.Priest1
    })
    Wait(17000)
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(menuped)
    DestroyCamera()
    destroyAllProps()
    letter = 1
    SendNUIMessage({
        action = 'openpriest',
        state = false
    })
    TriggerEvent('startFireworks')
    if me2 then
        TriggerServerEvent('0r-marriage-check-for-marry-s', GetStreetAndZone(GetEntityCoords(PlayerPedId())))
    end
end)

RegisterNUICallback('close', function()
    SetNuiFocus(false,false)
end)

RegisterNetEvent('0r-marriage-propose', function(id)
    print('[DEBUG] Client received propose event, id: ' .. tostring(id))
    local closestplayer, distance = GetClosestPlayer()
    print('[DEBUG] Closest player: ' .. tostring(closestplayer) .. ', distance: ' .. tostring(distance))
    
    if closestplayer ~= -1 then
        if distance <= 2.0 then
            local playerPed = PlayerPedId()
            local animDict = 'ultra@propose'
            local animName = 'propose'
            Prop = 'ultra_ringcase'
            PropBone = 28422
            PropPlacement = { 0.08, 0.01, -0.055, 0.0, 180.0, -90.0 }

            local propPl1, propPl2, propPl3, propPl4, propPl5, propPl6 = table.unpack(PropPlacement)

            -- Try to add prop, but don't fail if it doesn't work
            local propAdded = addPropToPlayer(Prop, 28422, propPl1, propPl2, propPl3, propPl4, propPl5, propPl6)
            if not propAdded then
                print('[WARNING] Could not add propose prop, continuing anyway...')
            end
            
            -- Request and play animation
            RequestAnimDict(animDict)
            local timeout = 0
            while not HasAnimDictLoaded(animDict) and timeout < 100 do
                Wait(10)
                timeout = timeout + 1
            end
            
            if HasAnimDictLoaded(animDict) then
                TaskPlayAnim(playerPed, animDict, animName, 8.0, 1.0, -1, 1)
                RemoveAnimDict(animDict)
            else
                print('[WARNING] Animation dictionary not loaded after timeout, continuing anyway...')
            end
            
            TriggerServerEvent('0r-marriage-propose-her', GetPlayerServerId(closestplayer), id)
        else
            Notify(Locs.noone, 'error')
        end
    else
        Notify(Locs.noone, 'error')
    end
end)

RegisterNetEvent('0r-marriage-show-menu', function(type, other, name)
    SetNuiFocus(true, true)
    if type == 'propose' then
        Proposer = other
        SendNUIMessage({
            action = 'propose',
            player = name
        })
    elseif type == 'certificate' then
        SendNUIMessage({
            action = 'certificate',
            data = other
        })
    end
end)

RegisterNUICallback('action', function(data, cb)
    local action = data.action
    SetNuiFocus(false, false)
    TriggerServerEvent('0r-marriage-make-action', action, Proposer)
end)

RegisterNetEvent('0r-marriage-no', function()
    destroyAllProps()
    ClearPedTasksImmediately(PlayerPedId())
    Wait(50)
    local animDict = "anim@heists@ornate_bank@hostages@hit"
    local animName = "hit_loop_ped_b"
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    Wait(5000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('0r-marriage-yes', function()
    TriggerEvent('startFireworks')
    destroyAllProps()
    ClearPedTasksImmediately(PlayerPedId())
    Wait(50)
    local animDict = "anim@arena@celeb@flat@solo@no_props@"
    local animName = "flip_a_player_a"
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    Wait(5000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('0r-marriage-no2', function()
    destroyAllProps()
    ClearPedTasksImmediately(PlayerPedId())
    Wait(50)
    local animDict = "anim@heists@ornate_bank@chat_manager"
    local animName = "fail"
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    Wait(4000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('0r-marriage-yes2', function()
    TriggerEvent('startFireworks')
    destroyAllProps()
    ClearPedTasksImmediately(PlayerPedId())
    Wait(50)
    local animDict = 'anim@mp_rollarcoaster'
    local animName = 'hands_up_idle_a_player_one'
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Citizen.Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 49)
    RemoveAnimDict(animDict)
    Wait(4000)
    ClearPedTasks(PlayerPedId())
end)

function addPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3, ply)
    destroyAllProps()
    local Player = PlayerPedId()
    if ply then Player = ply end
    local x, y, z = table.unpack(GetEntityCoords(Player))
    if not IsModelValid(prop1) then return false end
    if not HasModelLoaded(prop1) then 
        while not HasModelLoaded(joaat(prop1)) do
            RequestModel(joaat(prop1))
            Wait(10)
        end
    end
    prop = CreateObject(joaat(prop1), x, y, z + 0.2, true, true, true)
    if textureVariation ~= nil then
        SetObjectTextureVariation(prop, textureVariation)
    end
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(spawnedProp, prop)
    SetModelAsNoLongerNeeded(prop1)
    return true
end

function destroyAllProps()
    for _, v in pairs(spawnedProp) do 
        if v then
            DeleteEntity(v) 
            v = nil 
        end
    end
end

function LiveMap(id)
    CreateThread(function()
        while livemap do
            Wait(1000)
            TriggerServerEvent('0r-marriage-update-blip', id)
            if not livemap then 
                RemoveBlip(live_blip) 
                live_blip = nil
                break 
            end
        end
    end)
end

RegisterNetEvent('0r-marriage-update-blip-render', function(data)
    local color = 3

    local model = GetEntityModel(PlayerPedId())
    if model == "mp_m_freemode_01" or model == 1885233650 then
        color = 8
    end

    if not livemap then
        RemoveBlip(live_blip)
        return
    end
    if live_blip ~= nil then
        SetBlipCoords(live_blip, data.coords.x, data.coords.y, data.coords.z)
    else
        live_blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(live_blip, 57)
        SetBlipDisplay(live_blip, 4)
        SetBlipScale(live_blip, 0.5)
        SetBlipColour(live_blip, color)
        SetBlipAsShortRange(live_blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("("..data.name..") ".. Locs.YourFiance)
        EndTextCommandSetBlipName(live_blip)
    end
end)

RegisterNetEvent('0r-marriage-hug-rejectme', function()
    Notify('Rejected!', 'error')
end)

RegisterNetEvent('0r-marriage-hug-rejectother', function()
    Notify('Your Fiance rejected to hug!', 'error')
end)

RegisterNetEvent('0r-marriage-hug-acceptme', function()
    ClearPedTasksImmediately(PlayerPedId())
    Wait(300)

    local animDict = "mp_ped_interaction"
    local animName = "kisses_guy_a"
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    Wait(5000)
    ClearPedTasks(PlayerPedId())
end)

function TryDivorce()
    local closestplayer, distance, xx = GetClosestPlayer()
    if closestplayer > 0 then
        if distance < 2.5 then
            TriggerServerEvent('0r-marriage-divorce-req', GetPlayerServerId(closestplayer))
        else
            Notify(Locs.noone, 'error')
        end
    else
        Notify(Locs.noone, 'error')
    end
end

RegisterNetEvent('0r-marriage-divorce-req-c', function(myid, otherid)
    local alert = lib.alertDialog({
        header = Locs.WantDivorce,
        content = Locs.doyouwantdiv,
        centered = true,
        cancel = true
    })
     
    if alert == 'confirm' then
        TriggerServerEvent('0r-marriage-divorce', myid, otherid)
    end
end)

RegisterNetEvent('0r-marriage-hug-acceptother', function(player)
    local ply = PlayerPedId()
    local plyServerId = GetPlayerFromServerId(player) --GetPlayerServerId(player)
    local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())

    local SyncOffsetFront = 1.05
    local SyncOffsetSide = 0.0
    local SyncOffsetHeight = 0.0
    local SyncOffsetHeading = 180.1

    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
    local heading = GetEntityHeading(pedInFront)
    SetEntityHeading(ply, heading - SyncOffsetHeading)
    SetEntityCoordsNoOffset(ply, coords.x, coords.y, coords.z, 0)
    ClearPedTasksImmediately(PlayerPedId())
    Wait(300)

    local animDict = "mp_ped_interaction"
    local animName = "kisses_guy_a"
    while not HasAnimDictLoaded(animDict) do RequestAnimDict(animDict) Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 1.0, -1, 1)
    RemoveAnimDict(animDict)
    Wait(5000)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('startFireworks', function()
    RequestNamedPtfxAsset("scr_indep_fireworks")
    RequestNamedPtfxAsset("scr_indep_confetti")
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    
    local x, y, z = pos.x, pos.y, pos.z


    UseParticleFxAssetNextCall("scr_indep_fireworks")
    Wait(200)
    StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_firework_burst_spawn", x, y, z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    
    UseParticleFxAssetNextCall("scr_indep_confetti")
    Wait(200)
    StartNetworkedParticleFxNonLoopedAtCoord("scr_indep_confetti_spray", x, y, z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    
    Wait(2500)

    RemoveNamedPtfxAsset("scr_indep_fireworks")
    RemoveNamedPtfxAsset("scr_indep_confetti")
end)

function GetStreetAndZone(coords)
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return street .. ", " .. zone
end

function GetOffsetFromCoordsAndHeading(coords, heading, offsetX, offsetY, offsetZ)
    local headingRad = math.rad(heading)
    local x = offsetX * math.cos(headingRad) - offsetY * math.sin(headingRad)
    local y = offsetX * math.sin(headingRad) + offsetY * math.cos(headingRad)
    local z = offsetZ

    local worldCoords = vector4(
        coords.x + x,
        coords.y + y,
        coords.z + z,
        heading
    )
    
    return worldCoords
end

function CamCreate(npc)
	cam = CreateCam('DEFAULT_SCRIPTED_CAMERA')
	local coordsCam = GetOffsetFromCoordsAndHeading(npc, npc.w, 0.0, 1, .6)
	local coordsPly = npc
	SetCamCoord(cam, coordsCam)
	PointCamAtCoord(cam, coordsPly['x'], coordsPly['y'], coordsPly['z']+.6)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 500, true, true)

end

function DestroyCamera()
    RenderScriptCams(false, true, 500, 1, 0)
    DestroyCam(cam, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        DeleteEntity(menuped)
    end
end)

CreateThread(function()
    while true do 
        Wait(2500)
        if hud then
            TriggerServerEvent('0r-marriage-hud')
        end

        SendNUIMessage({
            action = 'hudstate',
            state = hud
        })
    end
end)

RegisterNetEvent('0r-marriage-update-hud', function(name, date)
    local color = 'blue'

    local model = GetEntityModel(PlayerPedId())
    if model == "mp_m_freemode_01" or model == 1885233650 then
        color = 'pink'
    end

    SendNUIMessage({
        action = 'updatehud',
        name = name,
        date = date,
        color = color
    })
end)

RegisterNetEvent('0r-marriage-close-hud', function()
    print('kapattım')
    hud = false
    SendNUIMessage({
        action = 'hudstate',
        state = hud
    })
    Wait(1500)
    hud = false
    SendNUIMessage({
        action = 'hudstate',
        state = hud
    })
end)


RegisterNetEvent('0r-marriage:openErpMenu', function()
    local elements = {}
    for k, v in pairs(Config.ERPAnims) do
        elements[#elements+1] = {
            title = v.Label,
            onSelect = function()
                TriggerEvent('0r-marriage-select-erp', k)
            end
        }
    end

    for k, v in pairs(Config.AddOnAnims) do
        elements[#elements+1] = {
            title = v.label,
            onSelect = function()
                target, distance = GetClosestPlayer()
                if (distance ~= -1 and distance < 3) then
                    TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), k)
                else
                    Notify(Locs.noone, 'error')
                end
            end
        }
    end

    lib.registerContext({
        id = '0r_marriage_erp',
        title = 'ERP MENU',
        options = elements
    })
    lib.showContext('0r_marriage_erp')
end)

RegisterNetEvent('0r-marriage-select-erp', function(id)
    local allowed = false
    if Config.ERPAnims[id]['Car'] then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            allowed = true
        else
            Notify(Locs.nocar, 'error')
        end
    else
        allowed = true
    end
    if allowed then
        local allowed = false
        local distance, closest = 999.0, nil

        for k, v in pairs(GetActivePlayers()) do
            src = GetPlayerServerId(v)
            if src ~= GetPlayerServerId(PlayerId()) then
                plr = GetPlayerFromServerId(src)
                dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(plr)))
                if not closest then
                    closest = src
                    distance = dist
                else
                    if dist < distance then
                        distance = dist
                        closest = src
                    end
                end
            end
        end

        if distance <= 2.0 then
            TriggerServerEvent('0r-marriage:requestSynced', closest, id)
        else
            Notify(Locs.noone, 'error')
        end
    end
end)

PlayAnim = function(Dict, Anim, Flag)
    LoadDict(Dict)
    TaskPlayAnim(PlayerPedId(), Dict, Anim, 8.0, -8.0, -1, Flag or 0, 0, false, false, false)
end

LoadDict = function(Dict)
    while not HasAnimDictLoaded(Dict) do 
        Wait(0)
        RequestAnimDict(Dict)
    end
end

RegisterNetEvent('0r-marriage:syncRequest', function(requester, id, name)
    Notify((Locs.erpreq):format(Config.ERPAnims[id]['RequesterLabel'], name) .. 'Accept: Y Reject: N', 'inform')
    local accepted = false
    local timer = GetGameTimer() + 10000
    while timer >= GetGameTimer() do 
        Wait(0)

        if IsControlJustReleased(0, 249) then
            break
        elseif IsControlJustReleased(0, 246) then
            accepted = true
            break
        end

    end

    if accepted then
        TriggerServerEvent('0r-marriage:syncAccepted', requester, id)
    end
end)

RegisterNetEvent('0r-marriage:playSynced', function(serverid, id, type)
    local anim = Config.ERPAnims[id][type]
    targetPlayerId = serverid  -- lets the shared cancel chain reach the other player

    local target = GetPlayerPed(GetPlayerFromServerId(serverid))
    if anim['Attach'] then
        local attach = anim['Attach']
        AttachEntityToEntity(PlayerPedId(), target, attach['Bone'], attach['xP'], attach['yP'], attach['zP'], attach['xR'], attach['yR'], attach['zR'], 0, 0, 0, 0, 2, 1)
    end

    Wait(750)

    if anim['Type'] == 'animation' then
        PlayAnim(anim['Dict'], anim['Anim'], anim['Flags'])
    end

    if type == 'Requester' then
        anim = Config.ERPAnims[id]['Accepter']
    else
        anim = Config.ERPAnims[id]['Requester']
    end

    local endTime = GetGameTimer() + 12500
    while GetGameTimer() < endTime do
        Wait(0)
        if cancelEmoteKey then
            cancelEmoteKey = false
            break
        end
    end

    ClearPedTasks(target)
    ClearPedTasks(PlayerPedId())
    DetachEntity(PlayerPedId())
    if targetPlayerId then
        TriggerServerEvent('ServerEmoteCancel', targetPlayerId)
        targetPlayerId = nil
    end
end)

RegisterNetEvent("SyncPlayEmote", function(emote, player)
    ClearPedTasksImmediately(PlayerPedId())
    Wait(300)
    targetPlayerId = player

    if emote ~= nil then
        LoadDict(emote.dict)
        TaskPlayAnim(PlayerPedId(), emote.dict, emote.anim, 5.0, 5.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(emote.dict)

        local endTime = GetGameTimer() + 15000
        while GetGameTimer() < endTime do
            Wait(0)
            if cancelEmoteKey then
                cancelEmoteKey = false
                break
            end
        end

        ClearPedTasksImmediately(PlayerPedId())
        DetachEntity(PlayerPedId())
        if targetPlayerId then
            TriggerServerEvent('ServerEmoteCancel', targetPlayerId)
            targetPlayerId = nil
        end
    end
end)

RegisterNetEvent("SyncPlayEmoteSource", function(emote, player)
    local ply = PlayerPedId()
    local plyServerId = GetPlayerFromServerId(player)
    local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer())

    local SyncOffsetFront = 1.0
    local SyncOffsetSide = 0.0
    local SyncOffsetHeight = 0.0
    local SyncOffsetHeading = 180.1

    local AnimationOptions = Config.AddOnAnims[emote] and Config.AddOnAnims[emote].AnimationOptions
    if AnimationOptions then
        if AnimationOptions.SyncOffsetFront then
            SyncOffsetFront = AnimationOptions.SyncOffsetFront + 0.0
        end
        if AnimationOptions.SyncOffsetSide then
            SyncOffsetSide = AnimationOptions.SyncOffsetSide + 0.0
        end
        if AnimationOptions.SyncOffsetHeight then
            SyncOffsetHeight = AnimationOptions.SyncOffsetHeight + 0.0
        end
        if AnimationOptions.SyncOffsetHeading then
            SyncOffsetHeading = AnimationOptions.SyncOffsetHeading + 0.0
        end

        local bone = AnimationOptions.bone or -1 -- No bone
        local xPos = AnimationOptions.xPos or 0.0
        local yPos = AnimationOptions.yPos or 0.0
        local zPos = AnimationOptions.zPos or 0.0
        local xRot = AnimationOptions.xRot or 0.0
        local yRot = AnimationOptions.yRot or 0.0
        local zRot = AnimationOptions.zRot or 0.0
        AttachEntityToEntity(ply, pedInFront, GetPedBoneIndex(pedInFront, bone), xPos, yPos, zPos, xRot, yRot, zRot,
            false, false, false, true, 1, true)
    end
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, SyncOffsetSide, SyncOffsetFront, SyncOffsetHeight)
    local heading = GetEntityHeading(pedInFront)
    SetEntityHeading(ply, heading - SyncOffsetHeading)
    SetEntityCoordsNoOffset(ply, coords.x, coords.y, coords.z, 0)
    ClearPedTasksImmediately(PlayerPedId())
    Wait(300)
    targetPlayerId = player
    LoadDict(Config.AddOnAnims[emote].dict)
    TaskPlayAnim(PlayerPedId(), Config.AddOnAnims[emote].dict, Config.AddOnAnims[emote].anim, 5.0, 5.0, -1, 1, 0, false, false, false)
    RemoveAnimDict(Config.AddOnAnims[emote].dict)
    local endTime = GetGameTimer() + 15000
    while GetGameTimer() < endTime do
        Wait(0)
        if cancelEmoteKey then
            cancelEmoteKey = false
            break
        end
    end

    ClearPedTasksImmediately(PlayerPedId())
    DetachEntity(PlayerPedId())
    if targetPlayerId then
        TriggerServerEvent('ServerEmoteCancel', targetPlayerId)
        targetPlayerId = nil
    end
end)

RegisterNetEvent("SyncCancelEmote", function(player)
    -- Clear for any matching player OR when we have no targetPlayerId tracked
    -- (covers ERP anims that set targetPlayerId = serverid)
    if not targetPlayerId or targetPlayerId == player then
        targetPlayerId = nil
        cancelEmoteKey = false
        ClearPedTasksImmediately(PlayerPedId())
        DetachEntity(PlayerPedId())
    end
end)

function CancelSharedEmote(ply)
    if targetPlayerId then
        TriggerServerEvent("ServerEmoteCancel", targetPlayerId)
        targetPlayerId = nil
    end
end

RegisterNetEvent("ClientEmoteRequestReceive", function(id, etype, target)
    isRequestAnim = true
    requestedemote = id

    local emote = Config.AddOnAnims[requestedemote]

    Notify((Locs.erpreq):format('', emote.label) .. ' Accept: Y Reject: N', 'inform')
    local timer = 3 * 1000
    while isRequestAnim do
        Citizen.Wait(5)
        timer = timer - 5
        if timer == 0 then
            isRequestAnim = false
        end

        if IsControlJustPressed(1, 246) then
            isRequestAnim = false

            TriggerServerEvent("ServerValidEmote", target, requestedemote, {
                anim = emote.anim2,
                dict = emote.dict2

            })
            break
        elseif IsControlJustPressed(1, 249) then
            isRequestAnim = false
            break
        end
    end
end)

ClearPedTasks(PlayerPedId())
DetachEntity(PlayerPedId())