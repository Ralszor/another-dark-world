---@class TestTwoCard : Card
local TestTwoCard, super = Class(Card)

function TestTwoCard:init()
    super.init(self, "dummy_punch", "Beat it up!")
    self.effect = "Take X damage:"
end

function TestTwoCard:onDecisionPhase(battle)
    super.onDecisionPhase(self, battle)

    local lines = {"Take X damage:"}
    local player_count = math.min(#battle:getNetworkParty(), 4)
    for count = 1, player_count do
        local label = count == 1 and "player" or "players"
        table.insert(lines, (count * 15) .. " for " .. count .. " " .. label)
    end
    self.effect = table.concat(lines, "\n")
end

function TestTwoCard:resolve(battle, member, selections)
    local pick_count = 0
    for _, party_member in ipairs(battle:getNetworkParty()) do
        if selections[battle:getCardSelectionKey(party_member)] == self.slot then
            pick_count = pick_count + 1
        end
    end
    return pick_count * 15
end

return TestTwoCard
