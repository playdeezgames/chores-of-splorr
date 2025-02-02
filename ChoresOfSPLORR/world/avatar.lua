local room = require("world.room")
local character = require("world.character")
local terrain = require("world.terrain")
local item = require("world.item")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local sfx = require("game.sfx")
local feature = require("world.feature")
local interaction_type = require("world.interaction_type")
local statistic_type   = require("world.statistic_type")
local utility = require "world.common.utility"
local M = {}
local data = {}

local function handle_terrain(character_id, next_room_id, next_column, next_row)
    local terrain_id = room.get_cell_terrain(next_room_id, next_column, next_row)
    if not terrain.is_passable(terrain_id) then
        local lock_type_id = room.get_cell_lock_type(next_room_id, next_column, next_row)
        if lock_type_id ~= nil then
            local key_item_type_id = lock_type.get_key_item_type_id(lock_type_id)
            if not character.has_item_type(character_id, key_item_type_id) then
                utility.show_message(lock_type.get_locked_message(lock_type_id))
                sfx.trigger(lock_type.get_fail_sfx(lock_type_id))
                return false
            else
                if lock_type.destroys_key(lock_type_id) then
                    character.remove_item_of_type(character_id, key_item_type_id)
                end
                room.set_cell_terrain(next_room_id, next_column, next_row, lock_type.to_terrain_id(lock_type_id))
                if lock_type.destroys_lock(lock_type_id) then
                    room.set_cell_lock_type(next_room_id, next_column, next_row, nil)
                end
                sfx.trigger(lock_type.get_success_sfx(lock_type_id))
                return false
            end
        end
        sfx.trigger(terrain.get_bump_sfx(terrain_id))
        return false
    end
    return true, terrain_id
end

local function handle_item(character_id, next_room_id, next_column, next_row)
    local item_id = room.get_cell_item(next_room_id, next_column, next_row)
    if item_id ~= nil then
        if character.can_pick_up_item(character_id, item_id) then
            local item_type_id = item.get_item_type(item_id)
            if item_type.can_pick_up(item_type_id) then
                sfx.trigger(item_type.get_pickup_sfx(item_type_id))
                room.set_cell_item(next_room_id, next_column, next_row, nil)
                character.add_item(character_id, item_id)
                local message = item_type.get_pickup_message(item_type_id)
                if message ~= nil then
                    utility.show_message(message)
                end
                return false
            end
        else
            sfx.trigger(sfx.GENERIC_FAIL)
            return false
        end
    end
    return true
end

local function handle_push_feature(character_id, next_room_id, next_column, next_row, delta_column, delta_row)
    local feature_id = room.get_cell_feature(next_room_id, next_column, next_row)
    if feature_id ~= nil then
        local context = {room_id=next_room_id, column=next_column, row=next_row, delta_column = delta_column, delta_row=delta_row, interaction = interaction_type.PUSH}
        if not feature.can_interact(feature_id, character_id, context) then
            sfx.trigger(feature.get_failure_sfx(feature_id))
            return false
        end
        feature.interact(feature_id, character_id, context)
        sfx.trigger(feature.get_success_sfx(feature_id))
        return false
    end
    return true
end

local function handle_other_character(next_room_id, next_column, next_row)
    local next_character_id = room.get_cell_character(next_room_id, next_column, next_row)
    if next_character_id ~= nil then
        --TODO: bump character sfx
        return false
    end
    return true
end

local function handle_teleport(next_room_id, next_column, next_row)
    local teleport_room_id, teleport_column, teleport_row = room.get_cell_teleport(next_room_id, next_column, next_row)
    if teleport_room_id ~= nil then
        next_room_id = teleport_room_id
        next_column = teleport_column
        next_row = teleport_row
    end
    return next_room_id, next_column, next_row
end

local function handle_pull_feature(character_id, prev_room_id, prev_column, prev_row, delta_column, delta_row)
    local feature_id = room.get_cell_feature(prev_room_id, prev_column, prev_row)
    if feature_id ~= nil then
        local context = {room_id=prev_room_id, column=prev_column, row=prev_row, delta_column = delta_column, delta_row=delta_row, interaction=interaction_type.PULL}
        if not feature.can_interact(feature_id, character_id, context) then
            sfx.trigger(feature.get_failure_sfx(feature_id))
        else
            feature.interact(feature_id, character_id, context)
            sfx.trigger(feature.get_success_sfx(feature_id))
        end
    end
end

local function move_other_room_characters(room_id, character_id)
    local other_characters = room.get_other_characters(room_id, character_id)
    for _, other_character_id in ipairs(other_characters) do
        character.do_move(other_character_id)
    end
end

local function move_room_features(room_id)
    local current_features = room.get_all_features(room_id)
    for _, current_feature_id in ipairs(current_features) do
        feature.do_move(current_feature_id)
    end
end

local function move_avatar(delta_column, delta_row)
    local character_id = M.get_character()

    local room_id, column, row = character.get_room(character_id)
    local next_room_id, next_column, next_row = room_id, column + delta_column, row + delta_row
    local prev_room_id, prev_column, prev_row = room_id, column - delta_column, row - delta_row

    --Rules Regarding Terrain
    local terrain_handled, terrain_id = handle_terrain(character_id, next_room_id, next_column, next_row)
    if not terrain_handled then
        return
    end

    --Rules Regarding Items
    if not handle_item(character_id, next_room_id, next_column, next_row) then
        return
    end

    --Rules Regarding PUSH Interactions With Features
    if not handle_push_feature(character_id, next_room_id, next_column, next_row, delta_column, delta_row) then
        return
    end

    --Rules Regarding Other Characters
    if not handle_other_character(next_room_id, next_column, next_row) then
        return
    end

    --Rules Regarding Teleportation
    next_room_id, next_column, next_row = handle_teleport(next_room_id, next_column, next_row)

    --Actually Move the Character
    sfx.trigger(terrain.get_step_sfx(terrain_id))
    character.change_statistic(character_id, statistic_type.MOVES, 1)
    room.set_cell_character(room_id, column, row, nil)
    room.set_cell_character(next_room_id, next_column, next_row, character_id)

    --Rules Regarding PULL Interactions With Features
    handle_pull_feature(character_id, prev_room_id, prev_column, prev_row, delta_column, delta_row)

    --Move Other Characters in the Room
    move_other_room_characters(room_id, character_id)

    --"Move" Features in the Room
    move_room_features(room_id)
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