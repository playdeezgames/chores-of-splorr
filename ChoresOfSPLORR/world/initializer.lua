local grimoire = require("game.grimoire")
local room = require("world.room")
local terrain = require("world.terrain")
local character = require("world.character")
local character_type = require("world.character_type")
local avatar = require("world.avatar")
local item = require("world.item")
local item_type = require("world.item_type")

local M = {}

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

	local item_id = item.create(item_type.KEY)
	room.set_item(room_id, 2, 2, item_id)
	
	local character_id = character.create(character_type.HERO)
	room.set_character(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, character_id)
	avatar.set_character(character_id)
	
	return room_id, character_id
end

function M.initialize()
	local room_id, character_id = initialize_starting_room()
end

return M