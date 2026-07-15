---@class Card
local Card = Class()

function Card:init(id, name, effect)
    self.id = id
    self.name = name
    self.effect = effect
    self.slot = 0
    self.revealed = false
end

function Card:setSlot(slot)
    self.slot = slot
end

---Called when players are allowed to inspect and choose the dealt cards.
function Card:onDecisionPhase(battle)
    self.revealed = true
end

---Called when the local player commits to this card.
function Card:onSelected(battle)
end

function Card:getName()
    return self.revealed and self.name or "???"
end

function Card:getEffect()
    return self.revealed and self.effect or ""
end

---Returns the exact damage this card deals to the local player.
function Card:resolve(battle, member, selections)
    return 0
end

return Card
