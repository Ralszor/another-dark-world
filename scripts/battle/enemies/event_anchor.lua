---@class EventAnchor : EnemyBattler
local EventAnchor, super = Class(EnemyBattler)

function EventAnchor:init()
    super.init(self)
    self.name = "Event"
    self.rarity = "event_anchor"
    self:setActor("dummy")
    self.visible = false
    self.selectable = false
    self.max_health = 1
    self.health = 1
    self.cards = {{}}
end

return EventAnchor
