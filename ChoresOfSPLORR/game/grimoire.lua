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
M.MSG_MOVE_UP = "move up"
M.MSG_MOVE_DOWN = "move down"
M.MSG_MOVE_LEFT = "move left"
M.MSG_MOVE_RIGHT = "move right"
M.URL_GUI = "/go#gui"
M.URL_SCENE = "/scene"
M.URL_MOVES_LABEL = "/scene#moves_label"
M.URL_SCORE_LABEL = "/scene#score_label"
M.GUI_MESSAGE_BOX = "message_box/box"
M.GUI_MESSAGE_BOX_TEXT = "message_box/text"
M.GUI_UP_ARROW = "up_arrow"
M.GUI_DOWN_ARROW = "down_arrow"
M.GUI_LEFT_ARROW = "left_arrow"
M.GUI_RIGHT_ARROW = "right_arrow"
M.INTENSITY_TILE_START = 245

return M