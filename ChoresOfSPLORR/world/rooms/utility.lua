local room = require("world.room")
local item = require("world.item")
local feature = require("world.feature")
local terrain = require("world.terrain")

local M = {}

function M.create_room_item(room_id, column, row, item_type_id)
	local item_id = item.create(item_type_id)
	room.set_cell_item(room_id, column, row, item_id)
	return item_id
end

function M.create_room_feature(room_id, column, row, feature_type_id)
	local feature_id = feature.create(feature_type_id)
	room.set_cell_feature(room_id, column, row, feature_id)
	return feature_id
end

function M.place_item(room_id, item_type_id)
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
function M.place_feature(room_id, feature_type_id)
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
function M.place_items(room_id, item_type_id, count, predicate)
	local result = {}
	while count > 0 do
		local item_id = M.place_item(room_id, item_type_id)
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
function M.place_features(room_id, feature_type_id, count, predicate)
	local result = {}
	while count > 0 do
		local feature_id = M.place_feature(room_id, feature_type_id)
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

return M