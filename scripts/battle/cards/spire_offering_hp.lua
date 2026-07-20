---@class SpireOfferingHPCard : Card
local SpireOfferingHPCard, super = Class(Card)

function SpireOfferingHPCard:init()
    super.init(self, "spire_offering_hp", "Offering", "Convert all TP to HP.")
end

function SpireOfferingHPCard:resolve(battle, member, selections)
    if not member or not member.chara then return 0 end
    local tension = math.max(0, math.floor(member.chara:getTension()))
    member.chara:addTension(-tension)
    Mod:syncRoundState(true)
    return -tension
end

return SpireOfferingHPCard
