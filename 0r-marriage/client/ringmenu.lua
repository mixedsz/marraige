-- Shared flag read by the emote loops in main.lua.
-- Set to true when the player presses X; each loop clears it after breaking.
cancelEmoteKey = false

RegisterCommand('+cancelEmote', function()
    cancelEmoteKey = true
end, false)

RegisterCommand('-cancelEmote', function()
    cancelEmoteKey = false
end, false)

RegisterKeyMapping('+cancelEmote', 'Cancel Synced Emote', 'keyboard', 'x')

-- /ringmenu command: asks the server to look up the marriage record and
-- push the ring menu to this client (same path as using the ring item).
RegisterCommand('ringmenu', function()
    TriggerServerEvent('0r-marriage:openRingMenuCmd')
end, false)

RegisterKeyMapping('ringmenu', 'Open Partner Menu', 'keyboard', '')
