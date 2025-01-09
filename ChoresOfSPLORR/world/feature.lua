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
function M.set_statistic(feature_id, statistic_type_id, statistic_value)
    local feature_data = data[feature_id]
    if feature_data.statistics == nil then
        feature_data.statistics = {}
    end
    feature_data.statistics[statistic_type_id] = statistic_value
end
return M