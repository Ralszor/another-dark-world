---@class TestTwoCard : Card
local TestTwoCard, super = Class(Card)

function TestTwoCard:init()
    super.init(self, "test_three", "Hey, Raly!", "If you choose this card alone, heal 35 HP.")
end

function TestTwoCard:resolve(battle, member, selections)
    local pick_count = 0
    for _, party_member in ipairs(battle:getNetworkParty()) do
        if selections[battle:getCardSelectionKey(party_member)] == self.slot then
            pick_count = pick_count + 1
        end
    end

    if pick_count == 1 then
        return -35
    end
    return 0
end

return TestTwoCard
