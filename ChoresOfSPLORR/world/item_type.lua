local M = {}
M.KEY = "KEY"
local descriptors = {
    [M.KEY] = {
        tile = 4,
        carryable = true
    }
}
function M.get_tile(item_type_id)
    return descriptors[item_type_id].tile
end
function M.can_pick_up(item_type_id)
    return descriptors[item_type_id].carryable
end
return M