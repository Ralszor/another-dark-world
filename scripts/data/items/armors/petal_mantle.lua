local item, super = Class(Item, "petal_mantle")

function item:init()
    super.init(self)

    -- Display name
    self.name = "PetalMantle"

    -- Item type
    self.type = "armor"
    self.icon = "ui/menu/icon/armor"

    -- Descriptions
    self.effect = ""
    self.shop = ""
    self.description = "A soft mantle woven from delicate\nflower petals."

    -- Shop settings
    self.price = 0
    self.can_sell = false

    -- Usage settings
    self.target = "none"
    self.usable_in = "none"
    self.result_item = nil
    self.instant = false

    -- Equip bonuses
    self.bonuses = {
        defense = 0,
    }

    self.bonus_name = nil
    self.bonus_icon = nil

    -- Equippable characters
    self.can_equip = {
        flowery = true,
        kris = false,
        susie = false,
        ralsei = false,
        noelle = false,
    }

    -- Character reactions
    self.reactions = {
        susie = "Looks comfy.",
        ralsei = "It's beautifully made!",
        noelle = "The petals are so pretty...",
        flowery = "Fits just right.",
    }
end

return item