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
return M