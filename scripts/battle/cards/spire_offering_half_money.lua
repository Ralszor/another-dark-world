---@class SpireOfferingHalfMoneyCard : Card
local SpireOfferingHalfMoneyCard, super = Class(Card)

function SpireOfferingHalfMoneyCard:init()
    super.init(
        self,
        "spire_offering_half_money",
        "Offering",
        "Convert half of all TP to D$."
    )
end

function SpireOfferingHalfMoneyCard:resolve(battle, member, selections)
    if not member or not member.chara then return 0 end
    local tension = math.max(0, math.floor(member.chara:getTension()))
    local converted = math.floor(tension / 2)
    member.chara:addTension(-converted)
    Mod:addLocalMoney(converted)
    Mod:syncRoundState(true)
    return 0
end

return SpireOfferingHalfMoneyCard
