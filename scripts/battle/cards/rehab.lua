---@class RehabCard : Card
local RehabCard, super = Class(Card)

function RehabCard:init()
    super.init(self, "rehab", "Rehab", "Receive 1 POISON.")
end

function RehabCard:resolve(battle, member, selections)
    battle:addPoisonStatus(1, self.slot)
    return 0
end

return RehabCard
