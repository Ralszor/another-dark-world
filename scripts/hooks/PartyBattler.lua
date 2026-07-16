---@class PartyBattler
local PartyBattler, super = HookSystem.hookScript(PartyBattler)

function PartyBattler:shouldRefuseFatalDamage(amount)
    return self.chara == Game.party[1]
        and Mod:getToken() == "refused"
        and not Mod:hasUsedRefusedResurrection()
        and self.chara:getHealth() > 0
        and self.chara:getHealth() - amount <= 0
end

function PartyBattler:removeHealth(amount, swoon)
    if self:shouldRefuseFatalDamage(amount) then
        Mod:useRefusedResurrection()
        Game.battle:startRefusedResurrection(self)
        self.chara:setHealth(0)
        self:down()
        return
    end
    super.removeHealth(self, amount, swoon)
end

function PartyBattler:removeHealthBroken(amount, swoon)
    if self:shouldRefuseFatalDamage(amount) then
        Mod:useRefusedResurrection()
        Game.battle:startRefusedResurrection(self)
        self.chara:setHealth(0)
        self:down()
        return
    end
    super.removeHealthBroken(self, amount, swoon)
end

return PartyBattler
