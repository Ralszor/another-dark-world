local item, super = Class(Item, "winning_smile")

function item:init()
    super.init(self)

    -- Display name
    self.name = "WinningSmile"

    -- Item type
    self.type = "weapon"

    -- Item icon shown in the equipment menu
    self.icon = "ui/menu/icon/flowery"

    -- Descriptions
    self.effect = ""
    self.shop = ""
    self.description = "A perfectly practiced smile.\nIt somehow counts as a weapon."

    -- Shop settings
    self.price = 0
    self.can_sell = false

    -- Usage settings
    self.target = "none"
    self.usable_in = "none"
    self.result_item = nil
    self.instant = false

    -- Equipment bonuses
    self.bonuses = {
        attack = 0,
    }

    -- Optional ability display
    self.bonus_name = nil
    self.bonus_icon = nil

    -- Only Flowery can equip this weapon
    self.can_equip = {
        flowery = true,
        kris = false,
        susie = false,
        ralsei = false,
        noelle = false,
    }

    -- Character reactions
    self.reactions = {
        susie = "That's not even a weapon!",
        ralsei = "What a... pleasant smile.",
        noelle = "Why does that smile make me nervous?",
        flowery = "Now that's a winning smile!",
    }
end

return item