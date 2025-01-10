local sfx = require("game.sfx")
local M = {}
M.FLOOR = "FLOOR"
M.WALL = "WALL"
M.OPEN_DOOR = "OPEN_DOOR"
M.CLOSED_DOOR = "CLOSED_DOOR"

local descriptors = {
	[M.FLOOR] = {
		tile = 1,
		passable = true,
		step_sfx = sfx.STEP
	},
	[M.WALL] = {
		tile = 2,
		passable = false,
		bump_sfx = sfx.BUMP
	},
	[M.OPEN_DOOR] = {
		tile = 5,
		passable = true,
		step_sfx = sfx.STEP
	},
	[M.CLOSED_DOOR] = {
		tile = 6,
		passable = false,
		bump_sfx = sfx.BUMP
	}
}

function M.get_tile(terrain_id)
	return descriptors[terrain_id].tile
end
function M.is_passable(terrain_id)
	return descriptors[terrain_id].passable
end
function M.get_bump_sfx(terrain_id)
	return descriptors[terrain_id].bump_sfx
end
function M.get_step_sfx(terrain_id)
	return descriptors[terrain_id].step_sfx
end
return M