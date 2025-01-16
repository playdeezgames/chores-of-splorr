local M = {}
M.BUMP = "BUMP"
M.LOCKED = "LOCKED"
M.UNLOCK = "UNLOCK"
M.STEP = "STEP"
M.PICK_UP_KEY = "PICK_UP_KEY"
M.PICK_UP_BROOM = "PICK_UP_BROOM"
M.SWEEP = "SWEEP"
M.NO_SWEEP = "NO_SWEEP"
M.DUST_BUNNY_SUMMON = "DUST_BUNNY_SUMMON"
M.DUST_BUNNY_TELEPORT = "DUST_BUNNY_TELEPORT"
M.GENERIC_FAIL = "GENERIC_FAIL"
M.DUST_BIN = "DUST_BIN"
M.SIGN = "SIGN"
M.DUST_INTO_BIN = "DUST_INTO_BIN"
M.DISH_WASHER = "DISH_WASHER"
M.CUPBOARD = "CUPBOARD"
M.DIRTY_DISH = "DIRTY_DISH"
M.WARDROBE = "WARDROBE"
M.WASHING_MACHINE = "WASHING_MACHINE"
M.SOAP_DISPENSER = "SOAP_DISPENSER"
M.FOLDING_TABLE = "FOLDING_TABLE"
M.PICK_UP_LAUNDRY_BASKET = "PICK_UP_LAUNDRY_BASKET"
M.DRYER = "DRYER"

function M.trigger(sfx_id)
    if sfx_id == nil then
        return
    end
    sound.play("/audio#"..sfx_id, {speed = 0.9 + math.random() * 0.2})
end
return M