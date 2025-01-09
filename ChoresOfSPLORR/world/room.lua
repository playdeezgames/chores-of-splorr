local character = require("world.character")
local M = {}
local data = {}
function M.create(columns, rows)
	local room_id = #data + 1
	local room_data = {}
	while #room_data < columns do
		local room_column_data = {}
		while #room_column_data < rows do
			local room_cell_data = {}
			table.insert(room_column_data, room_cell_data)
		end
		table.insert(room_data, room_column_data)
	end
	table.insert(data, room_data)
	return room_id
end
function M.set_terrain(room_id, column, row, terrain_id)
	local room_data = data[room_id]
	room_data[column][row].terrain_id = terrain_id
end
function M.get_terrain(room_id, column, row)
	local room_data = data[room_id]
	return room_data[column][row].terrain_id
end
function M.set_character(room_id, column, row, character_id)
	local room_data = data[room_id]
	local old_character_id = room_data[column][row].character_id
	if old_character_id ~= nil then
		character.set_room(old_character_id, nil, nil, nil)
	end
	room_data[column][row].character_id = character_id
	if character_id ~= nil then
		character.set_room(character_id, room_id, column, row)
	end
end
function M.get_character(room_id, column, row)
	local room_data = data[room_id]
	return room_data[column][row].character_id
end
function M.set_item(room_id, column, row, item_id)
	local room_data = data[room_id]
	room_data[column][row].item_id = item_id
end
function M.get_item(room_id, column, row)
	local room_data = data[room_id]
	return room_data[column][row].item_id
end
function M.set_lock_type(room_id, column, row, lock_type_id)
	local room_data = data[room_id]
	room_data[column][row].lock_type_id = lock_type_id
end
function M.get_lock_type(room_id, column, row)
	local room_data = data[room_id]
	return room_data[column][row].lock_type_id
end
function M.set_teleport(room_id, column, row, to_room_id, to_column,  to_row)
	local room_data = data[room_id]
	room_data[column][row].teleport = {
		room_id = to_room_id,
		column = to_column,
		row = to_row
	}
end
function M.get_teleport(room_id, column, row)
	local room_data = data[room_id]
	local teleport_data = room_data[column][row].teleport
	if teleport_data ~= nil then
		return teleport_data.room_id, teleport_data.column, teleport_data.row
	end
end
function M.set_feature(room_id, column, row, feature_id)
	local room_data = data[room_id]
	room_data[column][row].feature_id = feature_id
end
function M.get_feature(room_id, column, row)
	local room_data = data[room_id]
	return room_data[column][row].feature_id
end
return M