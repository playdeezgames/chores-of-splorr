local M = {}

M.DIRT_PILE = "DIRT_PILE"

local descriptors = {
    [M.DIRT_PILE] = {
        tile = 7
    }
}

function M.get_tile(feature_type_id)
    return descriptors[feature_type_id].tile
end
return M