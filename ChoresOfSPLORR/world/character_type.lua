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
function M.get_move_handler(character_type_id)
    return descriptors[character_type_id].move_handler
end
function M.set_move_handler(character_type_id, move_handler)
    descriptors[character_type_id].move_handler = move_handler
end
return M