local M = {}
M.HERO = "HERO"
local tiles = {
    [M.HERO] = 3
}
function M.get_tile(character_type_id)
    return tiles[character_type_id]
end
return M