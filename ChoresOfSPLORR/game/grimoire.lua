local M = {}

M.BOARD_COLUMNS = 25
M.BOARD_ROWS = 25
M.BOARD_CENTER_X = math.floor((1 + M.BOARD_COLUMNS)/2)
M.BOARD_CENTER_Y = math.floor((1 + M.BOARD_ROWS)/2)
M.INVENTORY_COLUMNS = 4
M.INVENTORY_ROWS = 4
M.MSG_TRIGGER_SFX = "trigger sfx"
M.MSG_SHOW_MESSAGE = "show message"
M.MSG_HIDE_MESSAGE = "hide message"
M.URL_GUI = "/go#gui"
M.URL_SCENE = "/scene"

return M