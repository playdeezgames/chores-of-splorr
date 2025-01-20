local feature_type = require("world.feature_type")
local feature = require("world.feature")
local metadata_type = require("world.metadata_type")
local statistic_type = require("world.statistic_type")
local interaction_type = require("world.interaction_type")
local character = require("world.character")
local utility = require("world.common.utility")
local item_type = require("world.item_type")
local rooms_utility = require("world.rooms.utility")
local item = require("world.item")
local characters_utility = require "world.characters.utility"
local M = {}

local WASHING_MACHINE_MAXIMUM_INTENSITY = 9
local WASHING_MACHINE_FRAME_TILES = {35, 36, 37, 38}

feature_type.set_do_move_handler(
	feature_type.WASHING_MACHINE,
	function(feature_id)
		if feature.get_metadata(feature_id, metadata_type.STATE) == metadata_type.STATE_WASHING then
			local timer = feature.change_statistic(feature_id, statistic_type.TIMER, -1)
			if timer == 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_CLEAN)
				--TODO: trigger sfx that washing machine is done.
			end
		end
	end)
feature_type.set_tile(
	feature_type.WASHING_MACHINE,
	function(feature_id, dt)
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			if feature.get_statistic(feature_id, statistic_type.INTENSITY) > 0 then
				return 34
			else
				return 33
			end
		elseif state == metadata_type.STATE_WASHING then
			local frame = feature.change_statistic(feature_id, statistic_type.FRAME, 1)
			if frame > #WASHING_MACHINE_FRAME_TILES then
				feature.set_statistic(feature_id, statistic_type.FRAME, 1)
			end
			return WASHING_MACHINE_FRAME_TILES[feature.get_statistic(feature_id, statistic_type.FRAME)]
		elseif state == metadata_type.STATE_CLEAN then
			if feature.get_statistic(feature_id, statistic_type.INTENSITY) > 0 then
				return 34
			else
				return 33
			end
		end
	end)
feature_type.set_can_interact(
	feature_type.WASHING_MACHINE,
	function(feature_id, character_id, context)
		if context.interaction ~= interaction_type.PUSH then
			return false
		end
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			if character.has_item_type(character_id, item_type.SOILED_SHIRT) then
				return true
			end
			if character.has_item_type(character_id, item_type.SOAP) then
				return true
			end
			utility.show_message("This is a WASHING MACHINE.\n\nIt converts SOILED SHIRTS into clean WET SHIRTS,\n\nwith the help of SOAP.")
			return false
		elseif state == metadata_type.STATE_WASHING then
			utility.show_message("The WASHING MACHINE is busy\n\nmaking SOILED SHIRTS into clean WET SHIRTS.")
			return false
		elseif state == metadata_type.STATE_CLEAN then
			--TODO: this is code duplicated in DRYER
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
		return true
	end)
feature_type.set_interact(
	feature_type.WASHING_MACHINE,
	function(feature_id, character_id, context)
		local state = feature.get_metadata(feature_id, metadata_type.STATE)
		if state == metadata_type.STATE_LOADING then
			if character.has_item_type(character_id, item_type.SOILED_SHIRT) then
				local item_id
				repeat
					item_id = character.remove_item_of_type(character_id, item_type.SOILED_SHIRT)
					if item_id ~= nil then
						local intensity = feature.change_statistic(feature_id, statistic_type.INTENSITY, 1)
						if intensity > WASHING_MACHINE_MAXIMUM_INTENSITY then
							rooms_utility.place_items(character.get_room(character_id), item_type.SOILED_SHIRT, intensity, function(_) end)
							utility.show_message("You have overloaded the WASHING_MACHINE!\n\nAs a result, it has exploded, \n\nthrowing SOILED SHIRTS all about the room.")
							feature.set_statistic(feature_id, statistic_type.INTENSITY, 0)
							return
						end
					end
				until item_id == nil
				return
			end
			if character.has_item_type(character_id, item_type.SOAP) then
				local intensity = feature.get_statistic(feature_id, statistic_type.INTENSITY)
				if intensity == 0 then
					utility.show_message("It is best to add SOILED SHIRTS prior to adding SOAP.")
					return
				end
				character.remove_item_of_type(character_id, item_type.SOAP)
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_WASHING)
				feature.set_statistic(feature_id, statistic_type.TIMER, 20)
				return
			end
		elseif state == metadata_type.STATE_CLEAN then
			local shirts_in_washer = feature.get_statistic(feature_id, statistic_type.INTENSITY) + 0
			local available_inventory_space = character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) - character.get_inventory_size(character_id)
			local shirts_to_remove = math.min(shirts_in_washer, available_inventory_space)
			local has_soiled_shirts = character.has_item_type(character_id, item_type.SOILED_SHIRT)
			local has_dry_shirts = character.has_item_type(character_id, item_type.DRY_SHIRT)
			local has_folded_shirts = character.has_item_type(character_id, item_type.FOLDED_SHIRT)
			while shirts_to_remove > 0 do
				feature.change_statistic(feature_id, statistic_type.INTENSITY, -1)
				shirts_in_washer = shirts_in_washer - 1
				shirts_to_remove = shirts_to_remove - 1
				local item_type_id = item_type.WASHED_SHIRT
				if has_soiled_shirts then
					item_type_id = item_type.SOILED_SHIRT
				end
				local item_id = item.create(item_type_id)
				character.add_item(character_id, item_id)
			end
			if has_soiled_shirts then
				utility.show_message("Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith SOILED SHIRTS\n\nmade the WET SHIRTS soiled.")
			elseif has_dry_shirts then
				utility.show_message("Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith DRY SHIRTS\n\nmade the DRY SHIRTS wet.")
				characters_utility.convert_character_item_type(character_id, item_type.DRY_SHIRT, item_type.WASHED_SHIRT)
			elseif has_folded_shirts then
				utility.show_message("Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith FOLDED SHIRTS\n\nmade the FOLDED SHIRTS wet.")
				characters_utility.convert_character_item_type(character_id, item_type.FOLDED_SHIRT, item_type.WASHED_SHIRT)
			end
			if shirts_in_washer == 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
			end
		end
	end)

return M