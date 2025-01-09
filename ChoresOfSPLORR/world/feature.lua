local M = {}
local data = {}
function M.create(feature_type_id)
    local feature_id = #data + 1
    local feature_data = {}
    feature_data.feature_type_id = feature_type_id
    data[feature_id] = feature_data
    return feature_id
end
function M.get_feature_type(feature_id)
    local feature_data = data[feature_id]
    return feature_data.feature_type_id
end
return M