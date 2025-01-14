local sfx = require("game.sfx")
local M = {}
M.KEY = "KEY"
M.BROOM = "BROOM"
M.DIRTY_DISH = "DIRTY_DISH"
M.CLEAN_DISH = "CLEAN_DISH"
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
    },
    [M.DIRTY_DISH] = {
        tile = 13,
        carryable = true,
        pickup_sfx_id = sfx.DIRTY_DISH,
        pickup_message = nil
    },
    [M.CLEAN_DISH] = {
        tile = 14,
        carryable = true,
        pickup_sfx_id = nil,
        pickup_message = nil
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