---@class NoiseMissMizzleCard : Card
local NoiseMissMizzleCard, super = Class(Card)

function NoiseMissMizzleCard:init()
    super.init(
        self,
        "noise_missmizzle",
        "Make some noise!",
        "Heal 20-40 HP."
    )
end

function NoiseMissMizzleCard:resolve(battle, member, selections)
    return -love.math.random(20, 40)
end

return NoiseMissMizzleCard
