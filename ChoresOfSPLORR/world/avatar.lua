local room = require("world.room")
local character = require("world.character")
local terrain = require("world.terrain")
local M = {}
local data = {}
local function move_avatar(delta_column, delta_row)
    local character_id = M.get_character()
    local room_id, column, row = character.get_room(character_id)
    local next_column = column + delta_column
    local next_row = row + delta_row
    local terrain_id = room.get_terrain(room_id, next_column, next_row)
    if not terrain.is_passable(terrain_id) then
        return
    end
    room.set_character(room_id, column, row, nil)
    room.set_character(room_id, next_column, next_row, character_id)
end
function M.set_character(character_id)
    data.character_id = character_id
end
function M.get_character()
    return data.character_id
end
function M.move_up()
    move_avatar(0, 1)
end
function M.move_right()
    move_avatar(1, 0)
end
function M.move_down()
    move_avatar(0, -1)
end
function M.move_left()
    move_avatar(-1, 0)
end
return M