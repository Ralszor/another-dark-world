---@class PartyBattler
local PartyBattler, super = HookSystem.hookScript(PartyBattler)

function PartyBattler:shouldRefuseFatalDamage(amount)
    return self.chara == Game.party[1]
        and Mod:getToken() == "refused"
        and not Mod:hasUsedRefusedResurrection()
        and self.chara:getHealth() > 0
        and self.chara:getHealth() - amount <= 0
end

function PartyBattler:grantEquipTension(amount)
    local damage = tonumber(amount) or 0
    if Game.party
        and self.chara == Game.party[1]
        and Mod:getToken() == "equip"
        and damage > 0
        and self.chara.addTension
    then
        self.chara:addTension(damage * 0.1)
    end
end

function PartyBattler:removeHealth(amount, swoon)
    self:grantEquipTension(amount)
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
    self:grantEquipTension(amount)
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
