local M = {}
M.KEY = "KEY"
local tiles = {
    [M.KEY] = 4
}
function M.get_tile(item_type_id)
    return tiles[item_type_id]
end
return M