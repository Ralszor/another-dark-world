---@class BattleCutscene
local BattleCutscene, super = HookSystem.hookScript(BattleCutscene)

---Displays synchronized dialogue that advances only after every active player confirms it.
function BattleCutscene:textAll(text, options)
    options = options or {}
    local battle = Game.battle
    local serial = battle:beginAllText(text, options)
    return self:wait(function()
        if not battle:isAllTextReady(serial) then return false end
        battle:closeAllText(serial)
        return true
    end)
end

return BattleCutscene
