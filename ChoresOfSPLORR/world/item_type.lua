local sfx = require("game.sfx")
local M = {}
M.KEY = "KEY"
local descriptors = {
    [M.KEY] = {
        tile = 4,
        carryable = true,
        pickup_sfx_id = sfx.PICK_UP
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
return M