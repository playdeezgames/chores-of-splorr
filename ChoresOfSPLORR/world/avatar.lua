local room = require("world.room")
local character = require("world.character")
local terrain = require("world.terrain")
local item = require("world.item")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local sfx = require("game.sfx")
local M = {}
local data = {}
local function move_avatar(delta_column, delta_row)
    local character_id = M.get_character()
    local room_id, column, row = character.get_room(character_id)

    local next_room_id = room_id
    local next_column = column + delta_column
    local next_row = row + delta_row

    local terrain_id = room.get_terrain(next_room_id, next_column, next_row)
    if not terrain.is_passable(terrain_id) then
        local lock_type_id = room.get_lock_type(next_room_id, next_column, next_row)
        if lock_type_id ~= nil then
            local key_item_type_id = lock_type.get_key_item_type_id(lock_type_id)
            if not character.has_item_type(character_id, key_item_type_id) then
                --TODO: fail SFX
                return
            else
                --TODO: destroy key if supposed to
                --TODO: change terrain
                --TODO: destroy lock if supposed to
                --TODO: succeeed SFX
                return
            end
        end
        --TODO: bump sfx
        return
    end

    local item_id = room.get_item(next_room_id, next_column, next_row)
    if item_id ~= nil then
        local item_type_id = item.get_item_type(item_id)
        if item_type.can_pick_up(item_type_id) then
            sfx.trigger(item_type.get_pickup_sfx(item_type_id))
            room.set_item(next_room_id, next_column, next_row, nil)
            character.add_item(character_id, item_id)
            return
        end
    end

    room.set_character(room_id, column, row, nil)
    room.set_character(next_room_id, next_column, next_row, character_id)
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