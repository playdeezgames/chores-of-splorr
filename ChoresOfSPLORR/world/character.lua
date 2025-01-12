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
function M.find_item_of_type(character_id, item_type_id)
    local character_data = data[character_id]
    for _, item_id in ipairs(character_data.inventory) do
        if item.get_item_type(item_id) == item_type_id then
            return item_id
        end
    end
    return nil
end
function M.remove_item(character_id, item_id)
    local character_data = data[character_id]
    local new_inventory = {}
    for _, candidate_item_id in ipairs(character_data.inventory) do
        if candidate_item_id ~= item_id then
            table.insert(new_inventory, candidate_item_id)
        end
    end
    character_data.inventory = new_inventory
end
function M.remove_item_of_type(character_id, item_type_id)
    local item_id = M.find_item_of_type(character_id, item_type_id)
    if item_id == nil then return end
    M.remove_item(character_id, item_id)
end
function M.set_statistic(character_id, statistic_type_id, statistic_value)
    local creature_data = data[character_id]
    if creature_data.statistics == nil then
        creature_data.statistics = {}
    end
    creature_data.statistics[statistic_type_id] = statistic_value
end
function M.get_statistic(character_id, statistic_type_id)
    local creature_data = data[character_id]
    if creature_data.statistics == nil then
        return nil
    end
    return creature_data.statistics[statistic_type_id]
end
return M