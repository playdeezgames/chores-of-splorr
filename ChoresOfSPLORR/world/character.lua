local item = require "world.item"
local M = {}
local data = {}
function M.create(character_type_id)
    local character_id = #data + 1
    local character_data = {
        inventory={}
    }
    character_data.character_type_id = character_type_id
    data[character_id] = character_data
    return character_id
end
function M.get_character_type(character_id)
    local character_data = data[character_id]
    return character_data.character_type_id
end
function M.set_room(character_id, room_id, column, row)
    local character_data = data[character_id]
    character_data.room_id = room_id
    character_data.column = column
    character_data.row = row
end
function M.get_room(character_id)
    local character_data = data[character_id]
    return character_data.room_id, character_data.column, character_data.row
end
function M.add_item(character_id, item_id)
    local character_data = data[character_id]
    table.insert(character_data.inventory, item_id)
end
function M.get_inventory(character_id, index)
    local character_data = data[character_id]
    return character_data.inventory[index]
end
function M.has_item_type(character_id, item_type_id)
    local character_data = data[character_id]
    for _, item_id in ipairs(character_data.inventory) do
        if item.get_item_type(item_id) == item_type_id then
            return true
        end
    end
    return false
end
return M