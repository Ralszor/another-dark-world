---@class GueiX1Card : Card
local GueiX1Card, super = Class(Card)

function GueiX1Card:init()
    super.init(self, "guei_x1", "Xercism")
    self.effect = "Gain 1-6 TP."
end

function GueiX1Card:onDecisionPhase(battle)
    super.onDecisionPhase(self, battle)
end

function GueiX1Card:resolve(battle, member, selections)
    if member and member.chara and member.chara.addTension then
        member.chara:addTension(love.math.random(1,6))
    end
    return 0
end

return GueiX1Card
