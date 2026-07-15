---@class TestTwoCard : Card
local TestTwoCard, super = Class(Card)

function TestTwoCard:init()
    super.init(self, "test_4", "Jarona!", "If you choose this card alone, take 5 damage. Otherwise, take 40.")
end

function TestTwoCard:resolve(battle, member, selections)
    local pick_count = 0
    for _, party_member in ipairs(battle:getNetworkParty()) do
        if selections[battle:getCardSelectionKey(party_member)] == self.slot then
            pick_count = pick_count + 1
        end
    end

    if pick_count == 1 then
        return 5
    end
    return 40
end

return TestTwoCard
