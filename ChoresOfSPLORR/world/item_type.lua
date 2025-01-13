local sfx = require("game.sfx")
local M = {}
M.KEY = "KEY"
M.BROOM = "BROOM"
local descriptors = {
    [M.KEY] = {
        tile = 4,
        carryable = true,
        pickup_sfx_id = sfx.PICK_UP_KEY,
        pickup_message = "You have found a KEY.\n\nProlly it opens a DOOR."
    },
    [M.BROOM] = {
        tile = 8,
        carryable = true,
        pickup_sfx_id = sfx.PICK_UP_BROOM,
        pickup_message = "You have a BROOM.\n\nI wonder what it's for?"
    }
}
function M.get_tile(item_type_id)
    return descriptors[item_type_id].tile
end
function M.can_pick_up(item_type_id)
    return descriptors[item_type_id].carryable
end
function M.get_pickup_sfx(item_type_id)
    return descriptors[item_type_id].pickup_sfx_id
end
function M.get_pickup_message(item_type_id)
    return descriptors[item_type_id].pickup_message
end
return M