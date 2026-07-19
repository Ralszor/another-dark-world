---@class WorldCutscene
local WorldCutscene, super = HookSystem.hookScript(WorldCutscene)

---Displays world dialogue locally, then waits for every active online player
---to finish that same line before the cutscene continues.
function WorldCutscene:textAll(text, portrait, actor, options)
    options = options or {}
    local sync_id = tostring(options.sync_id or text)
    self:text(text, portrait, actor, options)
    Mod:syncWorldTextReady(sync_id, true)
    self:wait(function()
        Mod:syncWorldTextReady(sync_id)
        return Mod:areWorldTextPlayersReady(sync_id)
    end)
    Mod:clearWorldTextReady(sync_id)
end

return WorldCutscene
