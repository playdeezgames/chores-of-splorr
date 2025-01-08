local terrain = require("world.terrain")
local item_type = require("world.item_type")
local M = {}
M.COMMON = "COMMON"
local descriptors = {
    [M.COMMON]={
        key_item_type_id = item_type.KEY,
        destroys_key = true,
        destroys_lock = true,
        to_terrain_id = terrain.OPEN_DOOR
    }
}
function M.get_key_item_type_id(lock_type_id)
    return descriptors[lock_type_id].key_item_type_id
end
function M.destroys_key(lock_type_id)
    return descriptors[lock_type_id].destroys_key
end
function M.destroys_lock(lock_type_id)
    return descriptors[lock_type_id].destroys_lock
end
function M.to_terrain_id(lock_type_id)
    return descriptors[lock_type_id].to_terrain_id
end
return M