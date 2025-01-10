local grimoire = require("game.grimoire")
local M = {}
M.BUMP = "BUMP"
M.LOCKED = "LOCKED"
M.UNLOCK = "UNLOCK"
M.STEP = "STEP"
M.PICK_UP = "PICK_UP"

function M.trigger(sfx_id)
    if sfx_id == nil then
        return
    end
    sound.play("/audio#"..sfx_id, {speed = 0.9 + math.random() * 0.2})
end
return M