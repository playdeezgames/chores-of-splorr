local grimoire = require("game.grimoire")
local room = require("world.room")
local terrain = require("world.terrain")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local metadata_type    = require("world.metadata_type")
local rooms_utility = require "world.rooms.utility"
local M = {}

local TOTAL_DISHES = 25

function M.initialize_second_room(starting_room_id)
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_cell_terrain(room_id, column, row, terrain_id)
		end
	end

	room.set_cell_terrain(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, terrain.CLOSED_DOOR)
	room.set_cell_lock_type(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, lock_type.COMMON)

	room.set_cell_terrain(room_id, 1, grimoire.BOARD_CENTER_Y, terrain.OPEN_DOOR)
	room.set_cell_teleport(starting_room_id, grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y, room_id, 2, grimoire.BOARD_CENTER_Y)
	room.set_cell_teleport(room_id, 1, grimoire.BOARD_CENTER_Y, starting_room_id, grimoire.BOARD_COLUMNS-1, grimoire.BOARD_CENTER_Y)

	rooms_utility.create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, 2, feature_type.DISH_WASHER)
	local cupboard_feature_id = rooms_utility.create_room_feature(room_id, 2, grimoire.BOARD_ROWS - 1, feature_type.CUPBOARD)
	feature.set_statistic(cupboard_feature_id, statistic_type.DISHES_REMAINING, TOTAL_DISHES)
	local sign_feature_id = rooms_utility.create_room_feature(room_id, 3, grimoire.BOARD_CENTER_Y, feature_type.SIGN)
	feature.set_metadata(sign_feature_id, metadata_type.MESSAGE, "Who left all of these DIRTY DISHES on the floor?\n\nWhy aren't there any TABLES in this room?\n\nSo many questions....")

	rooms_utility.place_items(
		room_id,
		item_type.DIRTY_DISH,
		TOTAL_DISHES,
		function(_) end)

	return room_id
end

return M