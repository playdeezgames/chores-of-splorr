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
local metadata_type    = require("world.metadata_type")
local rooms_utility = require "world.rooms.utility"
local M = {}

function M.initialize_starting_room()
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

	local exit_column, exit_row = grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y
	room.set_cell_terrain(room_id, exit_column, exit_row, terrain.CLOSED_DOOR)
	room.set_cell_lock_type(room_id, exit_column, exit_row, lock_type.COMMON)

	rooms_utility.create_room_item(room_id, grimoire.BOARD_CENTER_X - 1, grimoire.BOARD_CENTER_Y, item_type.BROOM)

	rooms_utility.create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, feature_type.DUST_BIN)
	local sign_feature_id = rooms_utility.create_room_feature(room_id, grimoire.BOARD_CENTER_X + 1, grimoire.BOARD_CENTER_Y, feature_type.SIGN)
	feature.set_metadata(sign_feature_id, metadata_type.MESSAGE, "This is a sign. Yer reading it.\n\nYou might also try interacting with other objects.")

	local character_id = character.create(character_type.HERO)
	room.set_cell_character(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, character_id)
	character.set_statistic(character_id, statistic_type.MOVES, 0)
	character.set_statistic(character_id, statistic_type.SCORE, 0)
	character.set_statistic(character_id, statistic_type.INVENTORY_SIZE, 16)
	avatar.set_character(character_id)

	local dirt_features = rooms_utility.place_features(
		room_id,
		feature_type.DIRT_PILE,
		25,
		function(feature_id)
			feature.set_statistic(feature_id, statistic_type.INTENSITY, 1)
		end)

	local Key_item_id = item.create(item_type.KEY)
	local dirt_feature_id = dirt_features[math.random(1, #dirt_features)]
	feature.set_item(dirt_feature_id, Key_item_id)

	return room_id, character_id
end

return M