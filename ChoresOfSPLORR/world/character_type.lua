local M = {}
M.HERO = "HERO"
local descriptors = {
    [M.HERO]={
        tile = 3
    }
}
function M.get_tile(character_type_id)
    return descriptors[character_type_id].tile
end
return M