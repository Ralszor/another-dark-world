---@class TestOneCard : Card
local TestOneCard, super = Class(Card)

function TestOneCard:init()
    super.init(self, "friend_1", "Cats can bite!", "Take 30 damage.")
end

function TestOneCard:resolve(battle, member, selections)
    return 30
end

return TestOneCard
