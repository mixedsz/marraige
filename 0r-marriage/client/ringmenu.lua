-- /ringmenu command: reopens the partner interaction menu at any time.
-- This is the guaranteed fallback for ox_inventory servers where the
-- ring item's "Use" button may not appear until items.lua is updated.
RegisterCommand('ringmenu', function()
    lib.showContext('0r_marriage_ring_menu')
end, false)

RegisterKeyMapping('ringmenu', 'Open Partner Menu', 'keyboard', '')
