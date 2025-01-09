local grimoire = require("game.grimoire")
local M = {}
M.BUMP = "BUMP"
M.LOCKED = "LOCKED"
M.UNLOCK = "UNLOCK"
M.STEP = "STEP"
M.PICK_UP = "PICK_UP"

function M.trigger(sfx_id)
    sound.play("/audio#"..sfx_id)
end
return M