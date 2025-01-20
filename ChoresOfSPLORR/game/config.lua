local M = {}

local CONFIG_FILE_NAME = "config"
local APPLICATION_ID = "ChoresOfSPLORR"
local config = {}

function M.load()
    local filename = sys.get_save_file(APPLICATION_ID, CONFIG_FILE_NAME)
    config = sys.load(filename)
end

function M.save()
    local filename = sys.get_save_file(APPLICATION_ID, CONFIG_FILE_NAME)
    sys.save(filename, config)
end

function M.get_muted()
    return config.muted or false
end

function M.set_muted(mutedness)
    config.muted = mutedness
    M.save()
end

M.load()

return M