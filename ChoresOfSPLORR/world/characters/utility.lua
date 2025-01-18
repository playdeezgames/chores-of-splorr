local character = require("world.character")
local item = require("world.item")
local M = {}

function M.convert_character_item_type(character_id, item_type_from, item_type_to)
	while character.has_item_type(character_id, item_type_from) do
		character.remove_item_of_type(character_id, item_type_from)
		character.add_item(character_id, item.create(item_type_to))
	end
end

return M