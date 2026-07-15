---@class WalkCard : Card
local WalkCard, super = Class(Card)

function WalkCard:init()
    super.init(
        self,
        "walk",
        "Walk",
        "Starwalker likes your walking.\nGain 8 TP."
    )
end

function WalkCard:resolve(battle, member, selections)
    if member and member.chara and member.chara.addTension then
        member.chara:addTension(8)
    end
    return 0
end

return WalkCard
