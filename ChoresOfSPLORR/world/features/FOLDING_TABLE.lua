local feature_type = require "world.feature_type"
local character = require("world.character")
local item_type =require("world.item_type")
local item =require("world.item")
local interaction_type = require("world.interaction_type")
local utility = require("world.common.utility")
local M = {}

feature_type.set_can_interact(
    feature_type.FOLDING_TABLE,
    function(feature_id, character_id, context)
        if context.interaction ~= interaction_type.PUSH then
            return false
        end
        if character.has_item_type(character_id, item_type.DRY_SHIRT) then
            return true
        end
        utility.show_message("This is a FOLDING TABLE\n\nyou use it to turn DRY SHIRTS\n\ninto FOLDED SHIRTS.")
        return false
    end)
feature_type.set_interact(
    feature_type.FOLDING_TABLE,
    function(feature_id, character_id, context)
        character.remove_item_of_type(character_id, item_type.DRY_SHIRT)
        local item_id = item.create(item_type.FOLDED_SHIRT)
        character.add_item(character_id, item_id)
    end)

return M