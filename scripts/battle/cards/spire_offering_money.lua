---@class SpireOfferingMoneyCard : Card
local SpireOfferingMoneyCard, super = Class(Card)

function SpireOfferingMoneyCard:init()
    super.init(
        self,
        "spire_offering_money",
        "Offering",
        "Convert all TP to D$."
    )
    self.tp_cost = 50
end

function SpireOfferingMoneyCard:resolve(battle, member, selections)
    if not member or not member.chara then return 0 end
    local tension = math.max(0, math.floor(member.chara:getTension()))
    member.chara:addTension(-tension)
    Mod:addLocalMoney(tension)
    Mod:syncRoundState(true)
    return 0
end

return SpireOfferingMoneyCard
