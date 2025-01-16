local sfx = require("game.sfx")
local M = {}

M.DIRT_PILE = "DIRT_PILE"
M.DUST_BIN = "DUST_BIN"
M.SIGN = "SIGN"
M.DISH_WASHER = "DISH_WASHER"
M.CUPBOARD = "CUPBOARD"
M.WARDROBE = "WARDROBE"
M.WASHING_MACHINE = "WASHING_MACHINE"
M.SOAP_DISPENSER = "SOAP_DISPENSER"
M.FOLDING_TABLE = "FOLDING_TABLE"
M.DRYER = "DRYER"

local descriptors = {
    [M.DIRT_PILE] = {
        tile = 7,
        failure_sfx=sfx.NO_SWEEP,
        success_sfx=sfx.SWEEP
    },
    [M.DUST_BIN] = {
        tile = 9,
        success_sfx=sfx.DUST_BIN
    },
    [M.SIGN] = {
        tile = 10,
        success_sfx=sfx.SIGN
    },
    [M.DISH_WASHER] = {
        tile = 12,
        success_sfx=sfx.DISH_WASHER
    },
    [M.CUPBOARD] = {
        tile = 15,
        success_sfx=sfx.CUPBOARD
    },
    [M.WARDROBE] = {
        tile = 15,
        success_sfx=sfx.WARDROBE
    },
    [M.WASHING_MACHINE] = {
        tile = 16,
        success_sfx=sfx.WASHING_MACHINE
    },
    [M.DRYER] = {
        tile = 16,
        success_sfx=sfx.DRYER
    },
    [M.SOAP_DISPENSER] = {
        tile = 17,
        success_sfx=sfx.SOAP_DISPENSER
    },
    [M.FOLDING_TABLE] = {
        tile = 24,
        success_sfx=sfx.FOLDING_TABLE
    }
}
function M.get_tile(feature_type_id)
    return descriptors[feature_type_id].tile
end
function M.set_can_interact(feature_type_id, callback)
    descriptors[feature_type_id].can_interact = callback
end
function M.get_can_interact(feature_type_id)
    return descriptors[feature_type_id].can_interact
end
function M.set_interact(feature_type_id, callback)
    descriptors[feature_type_id].interact = callback
end
function M.get_interact(feature_type_id)
    return descriptors[feature_type_id].interact
end
function M.get_failure_sfx(feature_type_id)
    return descriptors[feature_type_id].failure_sfx
end
function M.get_success_sfx(feature_type_id)
    return descriptors[feature_type_id].success_sfx
end
function M.get_do_move_handler(feature_type_id)
    return descriptors[feature_type_id].do_move_handler
end
function M.set_do_move_handler(feature_type_id, do_move_handler)
    descriptors[feature_type_id].do_move_handler = do_move_handler
end
return M