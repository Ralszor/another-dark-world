---@class TestOneCard : Card
local TestOneCard, super = Class(Card)

function TestOneCard:init()
    super.init(self, "dummy_hug", "Hug", "Take 15 damage.")
end

function TestOneCard:resolve(battle, member, selections)
    return 15
end

return TestOneCard
