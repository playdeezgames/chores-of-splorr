local feature_type = require("world.feature_type")
local interaction_type = require("world.interaction_type")
local character = require("world.character")
local item_type = require("world.item_type")
local utility = require("world.common.utility")
local item = require("world.item")
local M = {}

feature_type.set_can_interact(
	feature_type.SOAP_DISPENSER,
	function(feature_id, character_id, context)
		if context.interaction ~= interaction_type.PUSH then
			return false
		end
		if character.has_item_type(character_id, item_type.SOAP) then
			utility.show_message("Sorry, one SOAP per customer.\n\n(How does it know?)")
			return false
		end
		return true
	end)
feature_type.set_interact(
	feature_type.SOAP_DISPENSER,
	function(feature_id, character_id, context)
		local item_id = item.create(item_type.SOAP)
		character.add_item(character_id, item_id)
		utility.show_message("The SOAP DISPENSER gives you SOAP.")
	end)

return M