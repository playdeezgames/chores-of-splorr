local sfx = require("game.sfx")
local M = {}

M.KEY = "KEY"
M.BROOM = "BROOM"
M.DIRTY_DISH = "DIRTY_DISH"
M.CLEAN_DISH = "CLEAN_DISH"
M.LAUNDRY_BASKET = "LAUNDRY_BASKET"
M.SOILED_SHIRT = "SOILED_SHIRT"
M.WASHED_SHIRT = "WASHED_SHIRT"
M.DRY_SHIRT = "DRY_SHIRT"
M.FOLDED_SHIRT = "FOLDED_SHIRT"
M.SOAP = "SOAP"

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
    },
    [M.LAUNDRY_BASKET] = {
        tile = 18,
        carryable = true,
        pickup_sfx_id = sfx.PICK_UP_LAUNDRY_BASKET,
        pickup_message = nil
    },
    [M.SOILED_SHIRT] = {
        tile = 19,
        carryable = true,
        pickup_sfx_id = nil,
        pickup_message = nil
    },
    [M.WASHED_SHIRT] = {
        tile = 20,
        carryable = true,
        pickup_sfx_id = nil,
        pickup_message = nil
    },
    [M.DRY_SHIRT] = {
        tile = 21,
        carryable = true,
        pickup_sfx_id = nil,
        pickup_message = nil
    },
    [M.FOLDED_SHIRT] = {
        tile = 22,
        carryable = true,
        pickup_sfx_id = nil,
        pickup_message = nil
    },
    [M.SOAP] = {
        tile = 23,
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