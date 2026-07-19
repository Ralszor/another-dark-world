---@class WorshipMissMizzleCard : Card
local WorshipMissMizzleCard, super = Class(Card)

function WorshipMissMizzleCard:init()
    super.init(
        self,
        "worship_missmizzle",
        "Worship",
        "25% chance to take 30 damage. Otherwise, gain 10 D$."
    )
end

function WorshipMissMizzleCard:resolve(battle, member, selections)
    if love.math.random() <= 0.25 then
        return 30
    end
    Mod:addLocalMoney(10)
    Mod:syncRoundState(true)
    return 0
end

return WorshipMissMizzleCard
