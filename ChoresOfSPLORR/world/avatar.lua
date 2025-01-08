local M = {}
local data = {}
function M.set_character(character_id)
    data.character_id = character_id
end
function M.get_character()
    return data.character_id
end
return M