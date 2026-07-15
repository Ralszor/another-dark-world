---@class FriendXCard : Card
local FriendXCard, super = Class(Card)

function FriendXCard:init()
    super.init(self, "friend_x", "Tire'm out!", "25% to receive 1 BITE.")
end

function FriendXCard:resolve(battle, member, selections)
    if love.math.random() <= 0.25 then
        battle:animateBiteStatusFromCard(self.slot)
        battle:addBiteStatus()
    end
    return 0
end

return FriendXCard
