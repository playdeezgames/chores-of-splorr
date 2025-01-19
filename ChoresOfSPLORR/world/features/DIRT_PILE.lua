local feature_type = require("world.feature_type")
local character = require("world.character")
local utility = require("world.common.utility")
local interaction_type = require("world.interaction_type")
local item_type = require("world.item_type")
local room = require("world.room")
local terrain = require("world.terrain")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local character_type = require("world.character_type")
local sfx = require("game.sfx")
local M = {}

local DIRT_PILE_MAXIMUM_INTENSITY = 9
local DIRT_PILE_SCORE_MULTIPLIER = 10

feature_type.set_can_interact(
    feature_type.DIRT_PILE,
    function(feature_id, character_id, context)
        if not character.has_item_type(character_id, item_type.BROOM) then
			if context.interaction == interaction_type.PUSH then
				utility.show_message("This is a pile of DIRT.\n\nYou can use a BROOM to sweep it towards a DUST BIN.")
			end
            return false
        end
        local next_column, next_row = context.column + context.delta_column, context.row + context.delta_row
        local terrain_id = room.get_cell_terrain(context.room_id, next_column, next_row)
        if terrain_id ~= terrain.FLOOR then
            return false
        end
        local next_feature_id = room.get_cell_feature(context.room_id, next_column, next_row)
        if next_feature_id == nil then
            return true
        end
		local next_feature_type_id = feature.get_feature_type(next_feature_id)
		if next_feature_type_id == feature_type.DIRT_PILE then
			return true
		end
        return next_feature_type_id == feature_type.DUST_BIN
    end)
feature_type.set_interact(
    feature_type.DIRT_PILE,
    function(feature_id, character_id, context)
        room.set_cell_feature(context.room_id, context.column, context.row, nil)
		local item_id = feature.get_item(feature_id)
		if item_id ~= nil then
			room.set_cell_item(context.room_id, context.column, context.row, item_id)
			feature.set_item(feature_id, nil)
			--TODO: reveal item
		end
        local next_column, next_row = context.column + context.delta_column, context.row + context.delta_row
        local next_feature_id = room.get_cell_feature(context.room_id, next_column, next_row)
        if next_feature_id == nil then
            room.set_cell_feature(context.room_id, next_column, next_row , feature_id)
        else
            local next_feature_type_id = feature.get_feature_type(next_feature_id)
            if next_feature_type_id == feature_type.DIRT_PILE then
                local total_intensity = feature.get_statistic(next_feature_id, statistic_type.INTENSITY) + feature.get_statistic(feature_id, statistic_type.INTENSITY)
				if total_intensity <= DIRT_PILE_MAXIMUM_INTENSITY then
					feature.set_statistic(next_feature_id, statistic_type.INTENSITY, total_intensity)
				else
					local dust_bunny_character_id = character.create(character_type.DUST_BUNNY)
					room.set_cell_feature(context.room_id, next_column, next_row, nil)
					room.set_cell_character(context.room_id, next_column, next_row, dust_bunny_character_id)
					character.set_statistic(dust_bunny_character_id, statistic_type.INTENSITY, total_intensity)
					local feature_item_id = feature.get_item(next_feature_id)
					if feature_item_id ~= nil then
						character.add_item(dust_bunny_character_id, feature_item_id)
					end
					utility.show_message("You piled the DIRT too high...\n\n...and summoned a dread DUST BUNNY!")
					sfx.trigger(sfx.DUST_BUNNY_SUMMON)
				end
			elseif next_feature_type_id == feature_type.DUST_BIN then
				local score = DIRT_PILE_SCORE_MULTIPLIER * feature.get_statistic(feature_id, statistic_type.INTENSITY)
				character.change_statistic(character_id, statistic_type.SCORE, score)
				sfx.trigger(sfx.DUST_INTO_BIN)
            end
        end
    end)

return M