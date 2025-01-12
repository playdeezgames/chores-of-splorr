local M = {}
M.HERO = "HERO"
M.DUST_BUNNY = "DUST_BUNNY"
local descriptors = {
    [M.HERO]={
        tile = 3
    },
    [M.DUST_BUNNY]={
        tile = 11
    }
}
function M.get_tile(character_type_id)
    return descriptors[character_type_id].tile
end
return M