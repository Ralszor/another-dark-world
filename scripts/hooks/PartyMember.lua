---@class PartyMember
local PartyMember, super = HookSystem.hookScript(PartyMember)

local function ensureTension(member)
    member.tension = member.tension or {
        value = 0,
        max = 100,
        visible = false,
    }
    return member.tension
end

function PartyMember:init(...)
    super.init(self, ...)
    ensureTension(self)
end

function PartyMember:getTension()
    return ensureTension(self).value
end

function PartyMember:getMaxTension()
    return ensureTension(self).max
end

function PartyMember:setTension(value)
    local tension = ensureTension(self)
    tension.value = MathUtils.clamp(value, 0, tension.max)
    return tension.value
end

function PartyMember:addTension(amount)
    local previous = self:getTension()
    local value = self:setTension(previous + amount)
    local gained = value - previous

    if gained > 0 and Game and Game.battle and Game.battle.onPartyTensionAdded then
        Game.battle:onPartyTensionAdded(self, gained)
    end
    return value
end

function PartyMember:setTensionVisible(visible)
    ensureTension(self).visible = visible
end

function PartyMember:save()
    local data = super.save(self)
    local tension = ensureTension(self)
    data.anotherdoor_tension = {
        value = tension.value,
        max = tension.max,
        visible = tension.visible,
    }
    return data
end

function PartyMember:load(data)
    super.load(self, data)
    local saved = data.anotherdoor_tension
    local tension = ensureTension(self)
    if saved then
        tension.max = saved.max or tension.max
        tension.value = MathUtils.clamp(saved.value or tension.value, 0, tension.max)
        tension.visible = saved.visible or false
    end
end

return PartyMember
