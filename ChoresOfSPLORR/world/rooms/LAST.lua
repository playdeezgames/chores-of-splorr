local room = require "world.room"
local grimoire = require "game.grimoire"
local terrain = require "world.terrain"
local rooms_utility = require "world.rooms.utility"
local feature = require "world.feature"
local metadata_type = require "world.metadata_type"
local feature_type = require "world.feature_type"
local M = {}

function M.initialize_last_room(third_room_id)
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

    room.set_cell_terrain(room_id, grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y, terrain.OPEN_DOOR)
	room.set_cell_teleport(third_room_id, 1, grimoire.BOARD_CENTER_Y, room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_CENTER_Y)
	room.set_cell_teleport(room_id, grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y, third_room_id, 2, grimoire.BOARD_CENTER_Y)

	local sign_feature_id = rooms_utility.create_room_feature(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, feature_type.SIGN)
	feature.set_metadata(sign_feature_id, metadata_type.MESSAGE, "You have completed yer tasks!\n\nGood job!\n\nTomorrow, you can do them again!")

    return room_id
end

return M