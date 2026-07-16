---@class TakeCareCard : Card
local TakeCareCard, super = Class(Card)

function TakeCareCard:init()
    super.init(self, "take_care", "TakeCare", "33% chance to receive 3 POISON.")
end

function TakeCareCard:resolve(battle, member, selections)
    if love.math.random() <= 0.33 then
        battle:addPoisonStatus(3, self.slot)
    end
    return 0
end

return TakeCareCard
