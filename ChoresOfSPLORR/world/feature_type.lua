local sfx = require("game.sfx")
local M = {}

M.DIRT_PILE = "DIRT_PILE"
M.DUST_BIN = "DUST_BIN"
M.SIGN = "SIGN"
M.DISH_WASHER = "DISH_WASHER"
M.CUPBOARD = "CUPBOARD"

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
return M