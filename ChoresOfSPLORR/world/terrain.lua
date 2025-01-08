local M = {}
M.FLOOR = "FLOOR"
M.WALL = "WALL"
M.OPEN_DOOR = "OPEN_DOOR"
M.CLOSED_DOOR = "CLOSED_DOOR"

local tiles = {
	[M.FLOOR] = 1,
	[M.WALL] = 2,
	[M.OPEN_DOOR] = 5,
	[M.CLOSED_DOOR] = 6
}
local passable = {
	[M.FLOOR] = true,
	[M.WALL] = false,
	[M.OPEN_DOOR] = true,
	[M.CLOSED_DOOR] = false
}

function M.get_tile(terrain_id)
	return tiles[terrain_id]
end
function M.is_passable(terrain_id)
	return passable[terrain_id]
end
return M