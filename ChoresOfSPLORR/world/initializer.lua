require "world.characters.HERO"
require "world.characters.DUST_BUNNY"

require "world.features.WASHING_MACHINE"
require "world.features.DRYER"
require "world.features.SOAP_DISPENSER"
require "world.features.DIRT_PILE"
require "world.features.SIGN"
require "world.features.DUST_BIN"
require "world.features.CUPBOARD"
require "world.features.DISH_WASHER"
require "world.features.FOLDING_TABLE"
require "world.features.WARDROBE"

local starting_room = require "world.rooms.SWEEPING"
local second_room = require "world.rooms.DISHES"
local third_room = require "world.rooms.LAUNDRY"

local M = {}
math.randomseed(100000 * (socket.gettime() % 1))

function M.initialize()
	local starting_room_id = starting_room.initialize_starting_room()
	local second_room_id = second_room.initialize_second_room(starting_room_id)
	third_room.initialize_third_room(second_room_id)
end

return M