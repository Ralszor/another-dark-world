---@class LullabyMissMizzleCard : Card
local LullabyMissMizzleCard, super = Class(Card)

function LullabyMissMizzleCard:init()
    super.init(
        self,
        "lullaby_missmizzle",
        "Lullaby",
        "Remove all POISON or BITE. Receive 3-6 money."
    )
    self.tp_cost = 10
end

function LullabyMissMizzleCard:resolve(battle, member, selections)
    battle:clearOneLocalStatus()
    Mod:addLocalMoney(love.math.random(3, 6))
    Mod:syncRoundState(true)
    return 0
end

return LullabyMissMizzleCard
