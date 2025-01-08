local M = {}
local data = {}
function M.create(item_type_id)
    local item_id = #data + 1
    local item_data = {}
    item_data.item_type_id = item_type_id
    data[item_id] = item_data
    return item_id
end
function M.get_item_type(item_id)
    local item_data = data[item_id]
    return item_data.item_type_id
end
return M