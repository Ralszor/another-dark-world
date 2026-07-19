---@class WaterFlirtCard : Card
local WaterFlirtCard, super = Class(Card)

function WaterFlirtCard:init()
    super.init(self, "water_flirt", "Flirt", "If everybody chooses this card, Watercooler blushes.")
end

function WaterFlirtCard:resolve(battle, member, selections)
    for _, party_member in ipairs(battle:getNetworkParty()) do
        if party_member.active ~= false
            and selections[battle:getCardSelectionKey(party_member)] ~= self.slot
        then
            return 0
        end
    end

    local enemy = battle.enemies and battle.enemies[1]
    if enemy and enemy.id == "watercooler" then
        enemy:setAnimation("spared")
        Mod:setMizzleSecret(true)
    end
    return 0
end

return WaterFlirtCard
