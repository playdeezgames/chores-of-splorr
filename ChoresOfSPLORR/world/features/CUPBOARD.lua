local grimoire = require("game.grimoire")
local room = require("world.room")
local character = require("world.character")
local item = require("world.item")
local item_type = require("world.item_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local interaction_type = require("world.interaction_type")
local utility = require "world.common.utility"
local M = {}

feature_type.set_can_interact(
	feature_type.CUPBOARD,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.CUPBOARD,
	function(feature_id, character_id, _)
		if character.has_item_type(character_id, item_type.CLEAN_DISH) then
			character.remove_item_of_type(character_id, item_type.CLEAN_DISH)
			character.change_statistic(character_id, statistic_type.SCORE, 10)
			local dishes_remaining = feature.change_statistic(feature_id, statistic_type.DISHES_REMAINING, -1)
			if dishes_remaining < 1 then
				local key_item_id = item.create(item_type.KEY)
				local room_id = character.get_room(character_id)
				room.set_cell_item(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, key_item_id)
				utility.show_message("As you put away the last DISH,\n\na KEY magically appears.\n\nWTH?")
			end
		else
			utility.show_message("This is a CUPBOARD.\n\nYou use this to store CLEAN DISHES.")
		end
	end)

return M