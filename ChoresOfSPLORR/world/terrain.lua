local M = {}
M.FLOOR = "FLOOR"
M.WALL = "WALL"
M.OPEN_DOOR = "OPEN_DOOR"
M.CLOSED_DOOR = "CLOSED_DOOR"

local descriptors = {
	[M.FLOOR] = {
		tile = 1,
		passable = true
	},
	[M.WALL] = {
		tile = 2,
		passable = false
	},
	[M.OPEN_DOOR] = {
		tile = 5,
		passable = true
	},
	[M.CLOSED_DOOR] = {
		tile = 6,
		passable = false
	}
}

function M.get_tile(terrain_id)
	return descriptors[terrain_id].tile
end
function M.is_passable(terrain_id)
	return descriptors[terrain_id].passable
end
return M