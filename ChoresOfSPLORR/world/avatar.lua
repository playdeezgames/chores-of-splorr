local room = require("world.room")
local character = require("world.character")
local terrain = require("world.terrain")
local item = require("world.item")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local sfx = require("game.sfx")
local feature = require("world.feature")
local feature_type = require("world.feature_type")
local M = {}
local data = {}

feature_type.set_can_interact(
    feature_type.DIRT_PILE, 
    function(_, character_id, context)
        if not character.has_item_type(character_id, item_type.BROOM) then
            return false
        end
        local next_column, next_row = context.column + context.delta_column, context.row + context.delta_row
        local terrain_id = room.get_terrain(context.room_id, next_column, next_row)
        if terrain_id ~= terrain.FLOOR then
            return false
        end
        return room.get_feature(context.room_id, next_column, next_row) == nil
    end)
feature_type.set_interact(
    feature_type.DIRT_PILE, 
    function(feature_id, _, context)
        room.set_feature(context.room_id, context.column, context.row, nil)
        room.set_feature(context.room_id, context.column + context.delta_column, context.row + context.delta_row, feature_id)
    end)

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
                sfx.trigger(lock_type.get_fail_sfx(lock_type_id))
                return
            else
                if lock_type.destroys_key(lock_type_id) then
                    character.remove_item_of_type(character_id, key_item_type_id)
                end
                room.set_terrain(next_room_id, next_column, next_row, lock_type.to_terrain_id(lock_type_id))
                if lock_type.destroys_lock(lock_type_id) then
                    room.set_lock_type(next_room_id, next_column, next_row, nil)
                end
                sfx.trigger(lock_type.get_success_sfx(lock_type_id))
                return
            end
        end
        sfx.trigger(terrain.get_bump_sfx(terrain_id))
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

    local feature_id = room.get_feature(next_room_id, next_column, next_row)
    if feature_id ~= nil then
        local context = {room_id=next_room_id, column=next_column, row=next_row, delta_column = delta_column, delta_row=delta_row}
        if not feature.can_interact(feature_id, character_id, context) then
            sfx.trigger(feature.get_failure_sfx(feature_id))
            return
        end
        feature.interact(feature_id, character_id, context)
        sfx.trigger(feature.get_success_sfx(feature_id))
        return
    end

    local teleport_room_id, teleport_column, teleport_row = room.get_teleport(next_room_id, next_column, next_row)
    if teleport_room_id ~= nil then
        next_room_id = teleport_room_id
        next_column = teleport_column
        next_row = teleport_row
    end

    sfx.trigger(terrain.get_step_sfx(terrain_id))
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