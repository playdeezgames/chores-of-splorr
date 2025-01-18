local room = require("world.room")
local item = require("world.item")
local feature = require("world.feature")

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

return M