---@class Player
local Player, super = HookSystem.hookScript(Player)

function Player:isMovementEnabled()
    if Mod.spectating then
        return false
    end
    return super.isMovementEnabled(self)
end

return Player
