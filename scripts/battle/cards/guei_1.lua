---@class GueiCard : Card
local GueiCard, super = Class(Card)

function GueiCard:init()
    super.init(self, "guei_1", "Read Story")
    self.effect = "The last of you to take this card takes 20 damage."
end

function GueiCard:onDecisionPhase(battle)
    super.onDecisionPhase(self, battle)
end

function GueiCard:resolve(battle, member, selections)
    local last_picker_key
    for _, party_member in ipairs(battle:getNetworkParty()) do
        if selections[battle:getCardSelectionKey(party_member)] == self.slot then
            last_picker_key = battle:getCardSelectionKey(party_member)
        end
    end

    if member and battle:getCardSelectionKey(member) == last_picker_key then
        return 20
    end
    return 0
end

return GueiCard
