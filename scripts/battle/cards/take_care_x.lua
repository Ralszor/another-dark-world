---@class TakeCareXCard : Card
local TakeCareXCard, super = Class(Card)

function TakeCareXCard:init()
    super.init(self, "take_care_x", "TakeCareX", "10% chance to receive 5 POISON.")
end

function TakeCareXCard:resolve(battle, member, selections)
    if love.math.random() <= 0.1 then
        battle:addPoisonStatus(5, self.slot)
    end
    return 0
end

return TakeCareXCard
