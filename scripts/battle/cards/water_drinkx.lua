---@class WaterDrinkStrawCard : Card
local WaterDrinkStrawCard, super = Class(Card)

function WaterDrinkStrawCard:init()
    super.init(
        self,
        "water_drinkx",
        "Drink With a Straw",
        "50% chance to remove all of your effects."
    )
    self.tp_cost = 15
end

function WaterDrinkStrawCard:resolve(battle, member, selections)
    if love.math.random() <= 0.5 then
        battle:clearLocalStatuses()
    end
    return 0
end

return WaterDrinkStrawCard
