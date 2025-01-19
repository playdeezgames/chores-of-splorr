local character = require("world.character")
local item = require("world.item")
local item_type = require("world.item_type")
local feature_type = require("world.feature_type")
local interaction_type = require("world.interaction_type")
local utility = require "world.common.utility"
local M = {}

feature_type.set_can_interact(
	feature_type.DISH_WASHER,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.DISH_WASHER,
	function(_, character_id, _)
		if character.has_item_type(character_id, item_type.DIRTY_DISH) then
			character.remove_item_of_type(character_id, item_type.DIRTY_DISH)
			character.add_item(character_id, item.create(item_type.CLEAN_DISH))
		else
			utility.show_message("This is a DISH WASHER.\n\n(Yes, I know it looks like a WASHING MACHINE.)\n\nYou use this to make a DIRTY DISH into a CLEAN DISH.")
		end
	end)

return M