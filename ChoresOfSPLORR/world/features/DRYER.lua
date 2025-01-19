local feature = require("world.feature")
local feature_type = require "world.feature_type"
local metadata_type= require "world.metadata_type"
local character = require "world.character"
local item_type = require "world.item_type"
local utility = require "world.common.utility"
local interaction_type = require "world.interaction_type"
local statistic_type = require("world.statistic_type")
local item = require("world.item")
local M = {}

local DRYER_FRAME_TILES = {51, 52, 53, 54}

feature_type.set_can_interact(
	feature_type.DRYER,
	function(feature_id,character_id,context)
		if context.interaction ~= interaction_type.PUSH then
			return false
		end
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			if character.has_item_type(character_id, item_type.WASHED_SHIRT) then
				return true
			else
				utility.show_message("This is a DRYER.\n\nIt takes WET CLOTHES\n\nand turns them into DRY CLOTHES.")
				return false
			end
		elseif state == metadata_type.STATE_DRYING then
			utility.show_message("The DRYER is busy turning\n\nWET CLOTHES into DRY CLOTHES.")
			return false
		elseif state == metadata_type.STATE_DRY then
			--TODO: this is code duplicated in WASHING_MACHINE
			local has_inventory_space = character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) > character.get_inventory_size(character_id)
			if not has_inventory_space then
				utility.show_message("Yer inventory is full!")
				return false
			end
			local has_laundry_basket = character.has_item_type(character_id, item_type.LAUNDRY_BASKET)
			if not has_laundry_basket then
				utility.show_message("You need a LAUNDRY BASKET!")
				return false
			end
			return true
		end
		return false
	end)
feature_type.set_interact(
	feature_type.DRYER,
	function(feature_id, character_id, context)
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			local shirts_added = 0
			while character.has_item_type(character_id, item_type.WASHED_SHIRT) do
				character.remove_item_of_type(character_id, item_type.WASHED_SHIRT)
				feature.change_statistic(feature_id, statistic_type.INTENSITY, 1)
				shirts_added = shirts_added + 1
			end
			if shirts_added > 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_DRYING)
				feature.set_statistic(feature_id, statistic_type.TIMER, 20)
			end
		elseif state == metadata_type.STATE_DRY then
			local shirts_in_dryer = feature.get_statistic(feature_id, statistic_type.INTENSITY) + 0
			local available_inventory_space = character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) - character.get_inventory_size(character_id)
			local shirts_to_remove = math.min(shirts_in_dryer, available_inventory_space)
			local has_soiled_shirts = character.has_item_type(character_id, item_type.SOILED_SHIRT)
			local has_wet_shirts = character.has_item_type(character_id, item_type.WASHED_SHIRT)
			while shirts_to_remove > 0 do
				feature.change_statistic(feature_id, statistic_type.INTENSITY, -1)
				shirts_in_dryer = shirts_in_dryer - 1
				shirts_to_remove = shirts_to_remove - 1
				local item_type_id = item_type.DRY_SHIRT
				if has_soiled_shirts then
					item_type_id = item_type.SOILED_SHIRT
				elseif has_wet_shirts then
					item_type_id = item_type.WASHED_SHIRT
				end
				local item_id = item.create(item_type_id)
				character.add_item(character_id, item_id)
			end
			if has_wet_shirts then
				utility.show_message("Putting DRY SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith WET SHIRTS\n\nmade the DRY SHIRTS wet.")
			elseif has_soiled_shirts then
				utility.show_message("Putting DRY SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith SOILED SHIRTS\n\nmade the DRY SHIRTS soiled.")
			end
			if shirts_in_dryer == 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
			end
		end
	end)
feature_type.set_tile(
	feature_type.DRYER,
	function(feature_id, dt)
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			return 49
		elseif state == metadata_type.STATE_DRYING then
			local frame = feature.change_statistic(feature_id, statistic_type.FRAME, 1)
			if frame > #DRYER_FRAME_TILES then
				feature.set_statistic(feature_id, statistic_type.FRAME, 1)
			end
			return DRYER_FRAME_TILES[feature.get_statistic(feature_id, statistic_type.FRAME)]
		elseif state == metadata_type.STATE_DRY then
			return 50
		end
	end)
feature_type.set_do_move_handler(
	feature_type.DRYER,
	function(feature_id)
		if feature.get_metadata(feature_id, metadata_type.STATE) == metadata_type.STATE_DRYING then
			local timer = feature.change_statistic(feature_id, statistic_type.TIMER, -1)
			if timer == 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_DRY)
				--TODO: trigger sfx that washing machine is done.
			end
		end
	end)
	

return M