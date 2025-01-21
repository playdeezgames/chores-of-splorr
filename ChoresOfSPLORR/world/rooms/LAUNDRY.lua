local grimoire = require("game.grimoire")
local room = require("world.room")
local terrain = require("world.terrain")
local item_type = require("world.item_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local metadata_type    = require("world.metadata_type")
local rooms_utility = require "world.rooms.utility"
local lock_type = require "world.lock_type"
local M = {}

local TOTAL_CLOTHES = 25

function M.initialize_third_room(second_room_id)
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

	room.set_cell_terrain(room_id, 1, grimoire.BOARD_CENTER_Y, terrain.CLOSED_DOOR)
	room.set_cell_lock_type(room_id, 1, grimoire.BOARD_CENTER_Y, lock_type.COMMON)

	room.set_cell_terrain(room_id, grimoire.BOARD_CENTER_X, 1, terrain.OPEN_DOOR)
	room.set_cell_teleport(second_room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, room_id, grimoire.BOARD_CENTER_X, 2)
	room.set_cell_teleport(room_id, grimoire.BOARD_CENTER_X, 1, second_room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS - 1)

	local washing_machine_feature_id = rooms_utility.create_room_feature(room_id, 2, 2, feature_type.WASHING_MACHINE)
	feature.set_metadata(washing_machine_feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
	feature.set_statistic(washing_machine_feature_id, statistic_type.INTENSITY, 0)
	feature.set_statistic(washing_machine_feature_id, statistic_type.TIMER, 0)
	feature.set_statistic(washing_machine_feature_id, statistic_type.FRAME, 1)
	

	local dryer_feature_id = rooms_utility.create_room_feature(room_id, 2, 3, feature_type.DRYER)
	feature.set_metadata(dryer_feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
	feature.set_statistic(dryer_feature_id, statistic_type.INTENSITY, 0)
	feature.set_statistic(dryer_feature_id, statistic_type.TIMER, 0)
	feature.set_statistic(dryer_feature_id, statistic_type.FRAME, 1)

	local wardrobe_feature_id = rooms_utility.create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, feature_type.WARDROBE)
	feature.set_statistic(wardrobe_feature_id, statistic_type.CLOTHES_REMAINING, TOTAL_CLOTHES)

	rooms_utility.create_room_feature(room_id, 2, grimoire.BOARD_ROWS - 1, feature_type.FOLDING_TABLE)
	rooms_utility.create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, 2, feature_type.SOAP_DISPENSER)
	rooms_utility.create_room_item(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, item_type.LAUNDRY_BASKET)

	rooms_utility.place_items(
		room_id,
		item_type.SOILED_SHIRT,
		TOTAL_CLOTHES,
		function(_) end)

	return room_id
end

return M