local M = {}
M.KEY = "KEY"
local tiles = {
    [M.KEY] = 4
}
local carryable = {
    [M.KEY] = true
}
function M.get_tile(item_type_id)
    return tiles[item_type_id]
end
function M.can_pick_up(item_type_id)
    return carryable[item_type_id]
end
return M