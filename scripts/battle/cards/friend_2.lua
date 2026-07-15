---@class FriendBiteCard : Card
local FriendBiteCard, super = Class(Card)

function FriendBiteCard:init()
    super.init(self, "friend_2", "Surprise!", "Receive 1 BITE.")
end

function FriendBiteCard:onSelected(battle)
    battle:animateBiteStatusFromCard(self.slot)
end

function FriendBiteCard:resolve(battle, member, selections)
    battle:addBiteStatus()
    return 0
end

return FriendBiteCard
