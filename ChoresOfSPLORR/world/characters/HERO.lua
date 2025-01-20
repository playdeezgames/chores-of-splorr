local character_type = require "world.character_type"
local character = require "world.character"
local statistic_type = require "world.statistic_type"
local item = require "world.item"
local item_type = require "world.item_type"
local utility = require "world.common.utility"
local characters_utility = require "world.characters.utility"
local M = {}

character_type.set_can_pick_up_item_handler(
	character_type.HERO,
	function(character_id, item_id)
		if character.get_inventory_size(character_id) >= character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) then
			return false
		end
		local item_type_id = item.get_item_type(item_id)
		if item_type_id == item_type.SOILED_SHIRT then
			if not character.has_item_type(character_id, item_type.LAUNDRY_BASKET) then
				utility.show_message("When dealing with laundry,\n\ntis best to use a LAUNDRY BASKET.")
				return false
			end
			if character.has_item_type(character_id, item_type.WASHED_SHIRT) then
				characters_utility.convert_character_item_type(character_id, item_type.WASHED_SHIRT, item_type.SOILED_SHIRT)
				utility.show_message("Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith WET SHIRTS\n\nonly soiled the WET SHIRTS.")
			end
			if character.has_item_type(character_id, item_type.DRY_SHIRT) then
				characters_utility.convert_character_item_type(character_id, item_type.DRY_SHIRT, item_type.SOILED_SHIRT)
				utility.show_message("Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith DRY SHIRTS\n\nonly soiled the DRY SHIRTS.")
			end
			if character.has_item_type(character_id, item_type.FOLDED_SHIRT) then
				characters_utility.convert_character_item_type(character_id, item_type.FOLDED_SHIRT, item_type.SOILED_SHIRT)
				utility.show_message("Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith FOLDED SHIRTS\n\nonly soiled the FOLDED SHIRTS.")
			end
		end
		return true
	end)

return M