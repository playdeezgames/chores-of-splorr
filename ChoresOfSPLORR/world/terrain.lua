local M = {}
M.FLOOR = "FLOOR"
M.WALL = "WALL"

local tiles = {
	[M.FLOOR]=1,
	[M.WALL]=2
}

function M.get_tile(terrain_id)
	return tiles[terrain_id]
end
return M