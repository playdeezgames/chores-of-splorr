local feature_type = require "world.feature_type"
local M = {}

feature_type.set_can_interact(
	feature_type.DRYER, 
	function(feature_id,character_id,context) 
		return false 
	end)
feature_type.set_interact(
	feature_type.DRYER, 
	function(feature_id,character_id,context) 
	end)

return M