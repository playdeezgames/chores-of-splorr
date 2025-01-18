local grimoire = require("game.grimoire")
local room = require("world.room")
local terrain = require("world.terrain")
local character = require("world.character")
local character_type = require("world.character_type")
local avatar = require("world.avatar")
local item = require("world.item")
local item_type = require("world.item_type")
local lock_type = require("world.lock_type")
local feature_type = require("world.feature_type")
local feature = require("world.feature")
local statistic_type = require("world.statistic_type")
local interaction_type = require("world.interaction_type")
local metadata_type    = require("world.metadata_type")
local sfx              = require("game.sfx")

local DIRT_PILE_MAXIMUM_INTENSITY = 9
local DIRT_PILE_SCORE_MULTIPLIER = 10
local TOTAL_DISHES = 25
local TOTAL_CLOTHES = 25
local WASHING_MACHINE_MAXIMUM_INTENSITY = 9

local M = {}
math.randomseed(100000 * (socket.gettime() % 1))

local function show_message(text)
	msg.post(
			grimoire.URL_SCENE,
			grimoire.MSG_SHOW_MESSAGE,
			{text = text.."\n\n<SPACE> to close."})
end
local function create_room_item(room_id, column, row, item_type_id)
	local item_id = item.create(item_type_id)
	room.set_cell_item(room_id, column, row, item_id)
	return item_id
end
local function create_room_feature(room_id, column, row, feature_type_id)
	local feature_id = feature.create(feature_type_id)
	room.set_cell_feature(room_id, column, row, feature_id)
	return feature_id
end
local function place_item(room_id, item_type_id)
	local column, row = math.random(2, room.get_cell_columns(room_id) - 1), math.random(2, room.get_cell_rows(room_id) - 1)
	local terrain_id = room.get_cell_terrain(room_id, column, row)
	if not terrain.is_passable(terrain_id) then
		return nil
	end
	if room.get_cell_item(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_cell_character(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_cell_feature(room_id, column, row) ~= nil then
		return nil
	end
	local item_id = item.create(item_type_id)
	room.set_cell_item(room_id, column, row, item_id)
	return item_id
end
local function place_feature(room_id, feature_type_id)
	local column, row = math.random(1, room.get_cell_columns(room_id)), math.random(1, room.get_cell_rows(room_id))
	local terrain_id = room.get_cell_terrain(room_id, column, row)
	if not terrain.is_passable(terrain_id) then
		return nil
	end
	if room.get_cell_item(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_cell_character(room_id, column, row) ~= nil then
		return nil
	end
	if room.get_cell_feature(room_id, column, row) ~= nil then
		return nil
	end
	local feature_id = feature.create(feature_type_id)
	room.set_cell_feature(room_id, column, row, feature_id)
	return feature_id
end
local function place_items(room_id, item_type_id, count, predicate)
	local result = {}
	while count > 0 do
		local item_id = place_item(room_id, item_type_id)
		if item_id ~= nil then
			table.insert(result, item_id)
			count = count - 1
			if predicate ~= nil then
				predicate(item_id)
			end
		end
	end
	return result
end
local function place_features(room_id, feature_type_id, count, predicate)
	local result = {}
	while count > 0 do
		local feature_id = place_feature(room_id, feature_type_id)
		if feature_id ~= nil then
			table.insert(result, feature_id)
			count = count - 1
			if predicate ~= nil then
				predicate(feature_id)
			end
		end
	end
	return result
end
local function convert_character_item_type(character_id, item_type_from, item_type_to)
	while character.has_item_type(character_id, item_type_from) do
		character.remove_item_of_type(character_id, item_type_from)
		character.add_item(character_id, item.create(item_type_to))
	end
end

character_type.set_can_pick_up_item_handler(
	character_type.HERO,
	function(character_id, item_id)
		if character.get_inventory_size(character_id) >= character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) then
			return false
		end
		local item_type_id = item.get_item_type(item_id)
		if item_type_id == item_type.SOILED_SHIRT then
			if not character.has_item_type(character_id, item_type.LAUNDRY_BASKET) then
				show_message("When dealing with laundry,\n\ntis best to use a LAUNDRY BASKET.")
				return false
			end
			if character.has_item_type(character_id, item_type.WASHED_SHIRT) then
				convert_character_item_type(character_id, item_type.WASHED_SHIRT, item_type.SOILED_SHIRT)
				show_message("Putting SOILED SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith WET SHIRTS\n\nonly soiled the WET SHIRTS.")
			end
		end
		return true
	end)
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
			show_message("This is a WASHING MACHINE.\n\nIt converts SOILED SHIRTS into clean WET SHIRTS,\n\nwith the help of SOAP.")
			return false
		elseif state == metadata_type.STATE_WASHING then
			show_message("The WASHING MACHINE is busy\n\nmaking SOILED SHIRTS into clean WET SHIRTS.")
			return false
		elseif state == metadata_type.STATE_CLEAN then
			local has_inventory_space = character.get_statistic(character_id, statistic_type.INVENTORY_SIZE) > character.get_inventory_size(character_id)
			if not has_inventory_space then
				show_message("Yer inventory is full!")
				return false
			end
			local has_laundry_basket = character.has_item_type(character_id, item_type.LAUNDRY_BASKET)
			if not has_laundry_basket then
				show_message("You need a LAUNDRY BASKET!")
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
							place_items(character.get_room(character_id), item_type.SOILED_SHIRT, intensity, function(_) end)
							show_message("You have overloaded the WASHING_MACHINE!\n\nAs a result, it has exploded, \n\nthrowing SOILED SHIRTS all about the room.")
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
					show_message("It is best to add SOILED SHIRTS prior to adding SOAP.")
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
				show_message("Putting WET SHIRTS\n\ninto a LAUNDRY BASKET\n\nwith SOILED SHIRTS\n\nmade the WET SHIRTS soiled.")
			end
			if shirts_in_washer == 0 then
				feature.set_metadata(feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
			end
		end
	end)
feature_type.set_can_interact(
	feature_type.SOAP_DISPENSER, 
	function(feature_id, character_id, context) 
		if context.interaction ~= interaction_type.PUSH then
			return false
		end
		if character.has_item_type(character_id, item_type.SOAP) then
			show_message("Sorry, one SOAP per customer.\n\n(How does it know?)")
			return false
		end
		return true
	end)
feature_type.set_interact(
	feature_type.SOAP_DISPENSER, 
	function(feature_id, character_id, context)
		local item_id = item.create(item_type.SOAP)
		character.add_item(character_id, item_id)
		show_message("The SOAP DISPENSER gives you SOAP.")
	end)
feature_type.set_can_interact(
    feature_type.DIRT_PILE,
    function(feature_id, character_id, context)
        if not character.has_item_type(character_id, item_type.BROOM) then
			if context.interaction == interaction_type.PUSH then
				show_message("This is a pile of DIRT.\n\nYou can use a BROOM to sweep it towards a DUST BIN.")
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
					show_message("You piled the DIRT too high...\n\n...and summoned a dread DUST BUNNY!")
					sfx.trigger(sfx.DUST_BUNNY_SUMMON)
				end
			elseif next_feature_type_id == feature_type.DUST_BIN then
				local score = DIRT_PILE_SCORE_MULTIPLIER * feature.get_statistic(feature_id, statistic_type.INTENSITY)
				character.change_statistic(character_id, statistic_type.SCORE, score)
				sfx.trigger(sfx.DUST_INTO_BIN)
            end
        end
    end)
feature_type.set_can_interact(
    feature_type.SIGN,
    function(_, _, context)
        return context.interaction == interaction_type.PUSH
    end)
feature_type.set_interact(
	feature_type.SIGN,
	function(feature_id, _, _)
		show_message(feature.get_metadata(feature_id, metadata_type.MESSAGE))
	end)
feature_type.set_can_interact(
	feature_type.DUST_BIN,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.DUST_BIN,
	function(_, _, _)
		show_message("This is the DUST BIN.\n\nYou push DIRT in here.")
	end)
character_type.set_move_handler(
	character_type.DUST_BUNNY,
	function(character_id)
		local room_id, column, row = character.get_room(character_id)
		room.set_cell_character(room_id, column, row, nil)
		local done = false
		local next_column, next_row = column, row
		local dust_feature_id = feature.create(feature_type.DIRT_PILE)
		feature.set_statistic(dust_feature_id, statistic_type.INTENSITY, 1)
		room.set_cell_feature(room_id, column, row, dust_feature_id)
		local intensity = character.change_statistic(character_id, statistic_type.INTENSITY, -1)
		if intensity == 0 then
			local item_id = character.get_inventory(character_id, 1)
			if item_id ~= nil then
				feature.set_item(dust_feature_id, item_id)
			end
		end
		if intensity > 0 then
			repeat
				next_column = math.random(1, room.get_cell_columns(room_id))
				next_row = math.random(1, room.get_cell_rows(room_id))
				local next_character_id = room.get_cell_character(room_id, next_column, next_row)
				local next_item_id = room.get_cell_item(room_id, next_column, next_row)
				local next_terrain_id = room.get_cell_terrain(room_id, next_column, next_row)
				local next_feature_id = room.get_cell_feature(room_id, next_column, next_row)
				done = next_terrain_id == terrain.FLOOR and next_character_id == nil and next_feature_id == nil and next_item_id == nil
			until done
			room.set_cell_character(room_id, next_column, next_row, character_id)
		end
		sfx.trigger(sfx.DUST_BUNNY_TELEPORT)
	end)
feature_type.set_can_interact(
	feature_type.CUPBOARD,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.CUPBOARD,
	function(feature_id, character_id, _)
		if character.has_item_type(character_id, item_type.CLEAN_DISH) then
			character.remove_item_of_type(character_id, item_type.CLEAN_DISH)
			character.change_statistic(character_id, statistic_type.SCORE, 10)
			local dishes_remaining = feature.change_statistic(feature_id, statistic_type.DISHES_REMAINING, -1)
			if dishes_remaining < 1 then
				local key_item_id = item.create(item_type.KEY)
				local room_id = character.get_room(character_id)
				room.set_cell_item(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, key_item_id)
				show_message("As you put away the last DISH,\n\na KEY magically appears.\n\nWTH?")
			end
		else
			show_message("This is a CUPBOARD.\n\nYou use this to store CLEAN DISHES.")
		end
	end)
feature_type.set_can_interact(
	feature_type.DISH_WASHER,
	function(_, _, context)
		return context.interaction == interaction_type.PUSH
	end)
feature_type.set_interact(
	feature_type.DISH_WASHER,
	function(_, character_id, _)
		if character.has_item_type(character_id, item_type.DIRTY_DISH) then
			character.remove_item_of_type(character_id, item_type.DIRTY_DISH)
			character.add_item(character_id, item.create(item_type.CLEAN_DISH))
		else
			show_message("This is a DISH WASHER.\n\n(Yes, I know it looks like a WASHING MACHINE.)\n\nYou use this to make a DIRTY DISH into a CLEAN DISH.")
		end
	end)

local function initialize_starting_room()
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_cell_terrain(room_id, column, row, terrain_id)
		end
	end

	local exit_column, exit_row = grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y
	room.set_cell_terrain(room_id, exit_column, exit_row, terrain.CLOSED_DOOR)
	room.set_cell_lock_type(room_id, exit_column, exit_row, lock_type.COMMON)

	create_room_item(room_id, grimoire.BOARD_CENTER_X - 1, grimoire.BOARD_CENTER_Y, item_type.BROOM)

	create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, feature_type.DUST_BIN)
	local sign_feature_id = create_room_feature(room_id, grimoire.BOARD_CENTER_X + 1, grimoire.BOARD_CENTER_Y, feature_type.SIGN)
	feature.set_metadata(sign_feature_id, metadata_type.MESSAGE, "This is a sign. Yer reading it.\n\nYou might also try interacting with other objects.")

	local character_id = character.create(character_type.HERO)
	room.set_cell_character(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, character_id)
	character.set_statistic(character_id, statistic_type.MOVES, 0)
	character.set_statistic(character_id, statistic_type.SCORE, 0)
	character.set_statistic(character_id, statistic_type.INVENTORY_SIZE, 16)
	avatar.set_character(character_id)

	local dirt_features = place_features(
		room_id,
		feature_type.DIRT_PILE,
		25,
		function(feature_id)
			feature.set_statistic(feature_id, statistic_type.INTENSITY, 1)
		end)

	local Key_item_id = item.create(item_type.KEY)
	local dirt_feature_id = dirt_features[math.random(1, #dirt_features)]
	feature.set_item(dirt_feature_id, Key_item_id)

	return room_id, character_id
end

local function initialize_second_room(starting_room_id)
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_cell_terrain(room_id, column, row, terrain_id)
		end
	end

	room.set_cell_terrain(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, terrain.CLOSED_DOOR)
	room.set_cell_lock_type(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, lock_type.COMMON)

	room.set_cell_terrain(room_id, 1, grimoire.BOARD_CENTER_Y, terrain.OPEN_DOOR)
	room.set_cell_teleport(starting_room_id, grimoire.BOARD_COLUMNS, grimoire.BOARD_CENTER_Y, room_id, 2, grimoire.BOARD_CENTER_Y)
	room.set_cell_teleport(room_id, 1, grimoire.BOARD_CENTER_Y, starting_room_id, grimoire.BOARD_COLUMNS-1, grimoire.BOARD_CENTER_Y)

	create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, 2, feature_type.DISH_WASHER)
	local cupboard_feature_id = create_room_feature(room_id, 2, grimoire.BOARD_ROWS - 1, feature_type.CUPBOARD)
	feature.set_statistic(cupboard_feature_id, statistic_type.DISHES_REMAINING, TOTAL_DISHES)
	local sign_feature_id = create_room_feature(room_id, 3, grimoire.BOARD_CENTER_Y, feature_type.SIGN)
	feature.set_metadata(sign_feature_id, metadata_type.MESSAGE, "Who left all of these DIRTY DISHES on the floor?\n\nWhy aren't there any TABLES in this room?\n\nSo many questions....")

	place_items(
		room_id,
		item_type.DIRTY_DISH,
		TOTAL_DISHES,
		function(_) end)

	return room_id
end

local function initialize_third_room(second_room_id)
	local room_id = room.create(grimoire.BOARD_COLUMNS, grimoire.BOARD_ROWS)
	for column = 1, grimoire.BOARD_COLUMNS do
		for row = 1, grimoire.BOARD_ROWS do
			local terrain_id = terrain.FLOOR
			if column == 1 or row == 1 or column == grimoire.BOARD_COLUMNS or row == grimoire.BOARD_ROWS then
				terrain_id = terrain.WALL
			end
			room.set_cell_terrain(room_id, column, row, terrain_id)
		end
	end
	room.set_cell_terrain(room_id, grimoire.BOARD_CENTER_X, 1, terrain.OPEN_DOOR)
	room.set_cell_teleport(second_room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS, room_id, grimoire.BOARD_CENTER_X, 2)
	room.set_cell_teleport(room_id, grimoire.BOARD_CENTER_X, 1, second_room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_ROWS - 1)

	local washing_machine_feature_id = create_room_feature(room_id, 2, 2, feature_type.WASHING_MACHINE)
	feature.set_metadata(washing_machine_feature_id, metadata_type.STATE, metadata_type.STATE_LOADING)
	feature.set_statistic(washing_machine_feature_id, statistic_type.INTENSITY, 0)
	feature.set_statistic(washing_machine_feature_id, statistic_type.TIMER, 0)

	create_room_feature(room_id, 2, 3, feature_type.DRYER)
	create_room_feature(room_id, 2, grimoire.BOARD_ROWS - 1, feature_type.FOLDING_TABLE)
	create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, 2, feature_type.SOAP_DISPENSER)
	create_room_feature(room_id, grimoire.BOARD_COLUMNS - 1, grimoire.BOARD_ROWS - 1, feature_type.WARDROBE)
	create_room_item(room_id, grimoire.BOARD_CENTER_X, grimoire.BOARD_CENTER_Y, item_type.LAUNDRY_BASKET)

	place_items(
		room_id,
		item_type.SOILED_SHIRT,
		TOTAL_CLOTHES,
		function(_) end)

	--PUT AVATAR INTO ROOM FOR TESTING!
	room.set_cell_character(room_id, grimoire.BOARD_CENTER_X, 2, avatar.get_character())

	return room_id
end

function M.initialize()
	local starting_room_id = initialize_starting_room()
	local second_room_id = initialize_second_room(starting_room_id)
	initialize_third_room(second_room_id)
end

return M