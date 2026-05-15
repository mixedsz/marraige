-- /ringmenu command: asks the server to look up the marriage record and
-- push the ring menu to this client (same path as using the ring item).
RegisterCommand('ringmenu', function()
    TriggerServerEvent('0r-marriage:openRingMenuCmd')
end, false)

RegisterKeyMapping('ringmenu', 'Open Partner Menu', 'keyboard', '')
