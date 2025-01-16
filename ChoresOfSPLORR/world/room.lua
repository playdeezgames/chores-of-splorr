local character = require("world.character")
local M = {}
local data = {}
function M.create(columns, rows)
	local room_id = #data + 1
	local room_data = {cells={}}
	while #(room_data.cells) < columns do
		local room_column_data = {}
		while #room_column_data < rows do
			local room_cell_data = {}
			table.insert(room_column_data, room_cell_data)
		end
		table.insert(room_data.cells, room_column_data)
	end
	table.insert(data, room_data)
	return room_id
end
function M.get_cell_columns(room_id)
	local room_data = data[room_id].cells
	return #room_data
end
function M.get_cell_rows(room_id)
	local room_data = data[room_id].cells
	return #(room_data[1])
end
function M.set_cell_terrain(room_id, column, row, terrain_id)
	local room_data = data[room_id].cells
	room_data[column][row].terrain_id = terrain_id
end
function M.get_cell_terrain(room_id, column, row)
	local room_data = data[room_id].cells
	return room_data[column][row].terrain_id
end
function M.set_cell_character(room_id, column, row, character_id)
	local room_data = data[room_id].cells
	local old_character_id = room_data[column][row].character_id
	if old_character_id ~= nil then
		character.set_room(old_character_id, nil, nil, nil)
	end
	room_data[column][row].character_id = character_id
	if character_id ~= nil then
		character.set_room(character_id, room_id, column, row)
	end
end
function M.get_cell_character(room_id, column, row)
	local cell_data = data[room_id].cells
	return cell_data[column][row].character_id
end
function M.set_cell_item(room_id, column, row, item_id)
	local cell_data = data[room_id].cells
	cell_data[column][row].item_id = item_id
end
function M.get_cell_item(room_id, column, row)
	local cell_data = data[room_id].cells
	return cell_data[column][row].item_id
end
function M.set_cell_lock_type(room_id, column, row, lock_type_id)
	local cell_data = data[room_id].cells
	cell_data[column][row].lock_type_id = lock_type_id
end
function M.get_cell_lock_type(room_id, column, row)
	local cell_data = data[room_id].cells
	return cell_data[column][row].lock_type_id
end
function M.set_cell_teleport(room_id, column, row, to_room_id, to_column,  to_row)
	local cell_data = data[room_id].cells
	cell_data[column][row].teleport = {
		room_id = to_room_id,
		column = to_column,
		row = to_row
	}
end
function M.get_cell_teleport(room_id, column, row)
	local cell_data = data[room_id].cells
	local teleport_data = cell_data[column][row].teleport
	if teleport_data ~= nil then
		return teleport_data.room_id, teleport_data.column, teleport_data.row
	end
end
function M.set_cell_feature(room_id, column, row, feature_id)
	local cell_data = data[room_id].cells
	cell_data[column][row].feature_id = feature_id
end
function M.get_cell_feature(room_id, column, row)
	local cell_data = data[room_id].cells
	return cell_data[column][row].feature_id
end
function M.get_other_characters(room_id, character_id)
	local result = {}
	for column = 1, M.get_cell_columns(room_id) do
		for row = 1, M.get_cell_rows(room_id) do
			local candidate = M.get_cell_character(room_id, column, row)
			if candidate ~= nil and candidate ~= character_id then
				table.insert(result, candidate)
			end
		end
	end
	return result
end
function M.get_all_features(room_id)
	local result = {}
	for column = 1, M.get_cell_columns(room_id) do
		for row = 1, M.get_cell_rows(room_id) do
			local candidate = M.get_cell_feature(room_id, column, row)
			if candidate ~= nil then
				table.insert(result, candidate)
			end
		end
	end
	return result
end
return M