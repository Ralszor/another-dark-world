local Spire, super = Class(EnemyBattler)

function Spire:init()
    super.init(self)

    self.name = "Spire"
    self.rarity = "event_enemy"
    self:setActor("spire")
    self:setAnimation("idle")

    self.cards = {
        {"spire_offering_hp", "spire_offering_half_money"},
        {"spire_offering_money"},
    }

    self.max_health = 1
    self.health = 1
    self.attack = 0
    self.defense = 0
    self.money = 0
    self.experience = 0
    self.killable = false
    self.selectable = false
    self.text = {"* The Spire awaits an offering."}
end

function Spire:playOfferingAnimation()
    self:flash()
    self:setAnimation("top")

    if self.wings and self.wings.parent then self.wings:remove() end
    local wings = Sprite("event/wings", self.width / 2, self.height / 2)
    wings:setOrigin(0.5, 0.5)
    wings.layer = (self.sprite and self.sprite.layer or 0) + 1
    wings:setAnimation({
        "event/wings",
        0.06,
        false,
        callback = function(sprite)
            if sprite.parent then sprite:remove() end
        end,
    })
    self:addChild(wings)
    self.wings = wings

    Assets.playSound("grab")
    Assets.playSound("platswap")
end

return Spire
