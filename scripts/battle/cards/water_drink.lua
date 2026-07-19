---@class WaterDrinkCard : Card
local WaterDrinkCard, super = Class(Card)

function WaterDrinkCard:init()
    super.init(self, "water_drink", "Drink", "Heal 5-25 HP.")
end

function WaterDrinkCard:resolve(battle, member, selections)
    return -love.math.random(5, 25)
end

return WaterDrinkCard
