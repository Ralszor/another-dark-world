local item, super = Class(Item, "sunday_best")

function item:init()
    super.init(self)

    -- Display name
    self.name = "SundayBest"

    -- Item type
    self.type = "armor"
    self.icon = "ui/menu/icon/armor"

    -- Descriptions
    self.effect = ""
    self.shop = ""
    self.description = "A neat outfit reserved for special\noccasions."

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
        susie = "You actually clean up pretty well.",
        ralsei = "How elegant!",
        noelle = "You look very nice in that.",
        flowery = "Looking my best!",
    }
end

return item