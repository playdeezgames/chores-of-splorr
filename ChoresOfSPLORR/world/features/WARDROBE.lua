local feature_type = require "world.feature_type"
local interaction_type = require "world.interaction_type"
local utility = require "world.common.utility"
local item_type = require "world.item_type"
local character = require "world.character"
local statistic_type = require "world.statistic_type"
local feature = require "world.feature"
local rooms_utility = require "world.rooms.utility"
local M = {}

feature_type.set_can_interact(
	feature_type.WARDROBE,
	function(feature_id, character_id, context)
		return context.interaction == interaction_type.PUSH
	end)

feature_type.set_interact(
    feature_type.WARDROBE,
    function(feature_id, character_id, context)
        if character.has_item_type(character_id, item_type.FOLDED_SHIRT) then
            character.remove_item_of_type(character_id, item_type.FOLDED_SHIRT)
            character.change_statistic(character_id, statistic_type.SCORE, 10)
            local clothes_remaining = feature.change_statistic(feature_id, statistic_type.CLOTHES_REMAINING, -1)
            if clothes_remaining == 0 then
                rooms_utility.place_item(character.get_room(character_id), item_type.KEY)
                utility.show_message("With all of the CLOTHES\n\nin the WARDROBE,\n\nanother magical KEY appears!\n\nSeriously, what the?")
            end
            return
        end
        utility.show_message("This is a WARDROBE\n\n(it doesn't lead to NARNIA)\n\nyou put FOLDED SHIRTS in here.")
    end)

return M