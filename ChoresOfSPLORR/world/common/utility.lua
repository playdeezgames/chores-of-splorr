local grimoire = require "game.grimoire"
local M = {}

function M.show_message(text)
	msg.post(
			grimoire.URL_SCENE,
			grimoire.MSG_SHOW_MESSAGE,
			{text = text.."\n\n<SPACE> to close."})
end

return M
