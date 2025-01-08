local M = {}
M.FLOOR = "FLOOR"
M.WALL = "WALL"

local tiles = {
	[M.FLOOR] = 1,
	[M.WALL] = 2
}
local passable = {
	[M.FLOOR] = true,
	[M.WALL] = false
}

function M.get_tile(terrain_id)
	return tiles[terrain_id]
end
function M.is_passable(terrain_id)
	return passable[terrain_id]
end
return M