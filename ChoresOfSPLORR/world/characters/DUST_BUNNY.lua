local room = require("world.room")
local terrain = require("world.terrain")
local character = require("world.character")
local character_type = require("world.character_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local sfx = require("game.sfx")
local M = {}

character_type.set_move_handler(
	character_type.DUST_BUNNY,
	function(character_id)
		local room_id, column, row = character.get_room(character_id)
		room.set_cell_character(room_id, column, row, nil)
		local done = false
		local next_column, next_row = column, row
		local dust_feature_id = feature.create(feature_type.DIRT_PILE)
		feature.set_statistic(dust_feature_id, statistic_type.INTENSITY, 1)
		room.set_cell_feature(room_id, column, row, dust_feature_id)
		local intensity = character.change_statistic(character_id, statistic_type.INTENSITY, -1)
		if intensity == 0 then
			local item_id = character.get_inventory(character_id, 1)
			if item_id ~= nil then
				feature.set_item(dust_feature_id, item_id)
			end
		end
		if intensity > 0 then
			repeat
				next_column = math.random(1, room.get_cell_columns(room_id))
				next_row = math.random(1, room.get_cell_rows(room_id))
				local next_character_id = room.get_cell_character(room_id, next_column, next_row)
				local next_item_id = room.get_cell_item(room_id, next_column, next_row)
				local next_terrain_id = room.get_cell_terrain(room_id, next_column, next_row)
				local next_feature_id = room.get_cell_feature(room_id, next_column, next_row)
				done = next_terrain_id == terrain.FLOOR and next_character_id == nil and next_feature_id == nil and next_item_id == nil
			until done
			room.set_cell_character(room_id, next_column, next_row, character_id)
		end
		sfx.trigger(sfx.DUST_BUNNY_TELEPORT)
	end)

return M