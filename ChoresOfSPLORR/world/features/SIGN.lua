local feature_type = require("world.feature_type")
local feature = require("world.feature")
local interaction_type = require("world.interaction_type")
local metadata_type    = require("world.metadata_type")
local utility = require "world.common.utility"
local M = {}

feature_type.set_can_interact(
    feature_type.SIGN,
    function(_, _, context)
        return context.interaction == interaction_type.PUSH
    end)
feature_type.set_interact(
	feature_type.SIGN,
	function(feature_id, _, _)
		utility.show_message(feature.get_metadata(feature_id, metadata_type.MESSAGE))
	end)

return M