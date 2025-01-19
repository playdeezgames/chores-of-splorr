local feature_type = require("world.feature_type")
local interaction_type = require("world.interaction_type")
local utility = require "world.common.utility"
local M = {}

feature_type.set_can_interact(
	feature_type.DUST_BIN,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.DUST_BIN,
	function(_, _, _)
		utility.show_message("This is the DUST BIN.\n\nYou push DIRT in here.")
	end)

return M