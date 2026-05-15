-- ox_inventory v3+ automatically loads data/items.lua from every resource.
-- This registers the three marriage items as useable (consume = 0 keeps them
-- in the inventory after use) and wires the ring to a server event so the
-- partner menu opens when the player clicks Use.
--
-- If any of these items are already defined in your ox_inventory/data/items.lua
-- ox_inventory will print a duplicate warning and keep its own definition.
-- In that case just add  consume = 0  and the server event to your existing entry.

return {
    ['ring'] = {
        label       = 'Ring',
        weight      = 100,
        consume     = 0,
        description = 'A symbol of your love. Use it to open the partner menu.',
        server      = {
            event = '0r-marriage:useRingItem',
        },
    },

    ['roseboxred'] = {
        label       = 'Red Rose Box',
        weight      = 300,
        consume     = 0,
        description = 'Use this near the priest to propose marriage.',
    },

    ['scrap_paper'] = {
        label       = 'Marriage Certificate',
        weight      = 50,
        consume     = 0,
        description = 'Your official marriage certificate.',
    },
}
