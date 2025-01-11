local grimoire = require("game.grimoire")
local room = require("world.room")
local terrain = require("world.terrain")
local character = require("world.character")
local character_type = require("world.character_type")
local avatar = require("world.avatar")
local item = require("world.item")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")

local M = {}
math.randomseed(100000 * (socket.gettime() % 1))

local function create_room_item(room_id, column, row, item_type_id)
	local item_id = item.create(item_type_id)
	room.set_item(room_id, column, row, item_id)
	return item_id
end

local function create_room_feature(room_id, column, row, feature_type_id)
	local feature_id = feature.create(feature_type_id)
	room.set_feature(room_id, column, row, feature_id)
	return feature_id
end

local function place_feature(room_id, feature_type_id)
	local column, row = math.random(1, room.get_columns(room_id)), math.random(1, room.get_rows(room_id))
	local terrain_id = room.get_terrain(room_id, column, row)
	if not terrain.is_passable(terrain_id) then
		return nil
	end
	if room.get_item(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_character(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_feature(room_id, column, row) ~= nil then
		return nil
	end
	local feature_id = feature.create(feature_type_id)
	room.set_feature(room_id, column, row, feature_id)
	return feature_id
end

local function place_features(room_id, feature_type_id, count, predicate)
	while count > 0 do
		local feature_id = place_feature(room_id, feature_type_id)
		if feature_id ~= nil then
			count = count - 1
			if predicate ~= nil then
				predicate(feature_id)
			end
		end
	end
end

local function initialize_starting_room()
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_terrain(room_id, column, row, terrain_id)
		end
	end

	local exit_column, exit_row = grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y
	room.set_terrain(room_id, exit_column, exit_row, terrain.CLOSED_DOOR)
	room.set_lock_type(room_id, exit_column, exit_row, lock_type.COMMON)

	create_room_item(room_id, 2, 2, item_type.KEY)
	create_room_item(room_id, grimoire.BOARD_CENTER_X - 1, grimoire.BOARD_CENTER_Y, item_type.BROOM)

	create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, feature_type.DUST_BIN)
	local sign_feature_id = create_room_feature(room_id, grimoire.BOARD_CENTER_X + 1, grimoire.BOARD_CENTER_Y, feature_type.SIGN)


	local character_id = character.create(character_type.HERO)
	room.set_character(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, character_id)
	avatar.set_character(character_id)

	place_features(
		room_id, 
		feature_type.DIRT_PILE, 
		25, 
		function(feature_id)
			feature.set_statistic(feature_id, statistic_type.INTENSITY, 1)
		end)
	
	return room_id, character_id
end

local function initialize_second_room(starting_room_id)
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_terrain(room_id, column, row, terrain_id)
		end
	end
	room.set_terrain(room_id, 1, grimoire.BOARD_CENTER_Y, terrain.OPEN_DOOR)
	room.set_teleport(starting_room_id, grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y, room_id, 2, grimoire.BOARD_CENTER_Y)
	room.set_teleport(room_id, 1, grimoire.BOARD_CENTER_Y, starting_room_id, grimoire.BOARD_COLUMNS-1, grimoire.BOARD_CENTER_Y)
	return room_id
end

function M.initialize()
	local starting_room_id, avatar_character_id = initialize_starting_room()
	initialize_second_room(starting_room_id)
end

return M