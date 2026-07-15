local character, super = Class(PartyMember, "flowery")

function character:init()
    super.init(self)

    -- Display name
    self.name = "Flowery"

    -- Actor (handles overworld/battle sprites)
    self:setActor("flowery")

    -- Display level (saved to the save file)
    self.level = 99
    -- Default title / class (saved to the save file)
    self.title = "Room Mate\nYour Dad's his\nbest friend"

    -- Determines which character the soul comes from (higher number = higher priority)
    self.soul_priority = -1
    -- The color of this character's soul (optional, defaults to red)
    
    -- The color of this character's soul (optional, defaults to red)
    self.soul_color = {0.9960784314, 0.8980392157, 0.0078431373}

    -- Whether the party member can act / use spells
    self.has_act = false
    self.has_spells = true

    -- Whether the party member can use their X-Action
    self.has_xact = true
    -- X-Action name (displayed in this character's spell menu)
    self.xact_name = "F-Action"

    -- Spells


    -- Current health (saved to the save file)
    self.health = 999

    -- Base stats (saved to the save file)
    self.stats = {
        health = 999,
        attack = 99,
        defense = 99,
        magic = 99,
    }

    -- Weapon icon in equip menu
    self.weapon_icon = "party/flowery/menu/equip/flowery"

    -- Equipment (saved to the save file)
    self:setWeapon("winning_smile")
    self:setArmor(1, "petal_mantle")
    self:setArmor(2, "sunday_best")

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "light/pencil"
    self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    
    -- Character color (for action box outline and HP bar)
    self.color = {0.9960784314, 0.8980392157, 0.0078431373}
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = nil
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.attack_bar_color = nil
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = nil
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = nil

    -- Head icon in the equip / power menu
    self.menu_icon = "party/flowery/head"
    -- Path to head icons used in battle
    self.head_icons = "party/flowery/icon"
    -- Name sprite (optional)
    self.name_sprite = "party/flowery/name"

    -- Effect shown above enemy after attacking it
    self.attack_sprite = "effects/attack/slap_n"
    -- Sound played when this character attacks
    self.attack_sound = "laz_c"
    -- Pitch of the attack sound
    self.attack_pitch = 1

    -- Battle position offset (optional)
    self.battle_offset = {2, 13}
    -- Head icon position offset (optional)
    self.head_icon_offset = {0, -8}
    -- Menu icon position offset (optional)
    self.menu_icon_offset = {0, -5}

    -- Message shown on gameover (optional)
    self.gameover_message = nil
end

function character:drawPowerStat(index, x, y, menu)
    if index == 1 then
        local icon = Assets.getTexture("ui/menu/icon/flowery")
        Draw.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Flowers:    99", x, y, 0, 1, 1)
        return true
    elseif index == 2 then
        local icon = Assets.getTexture("ui/menu/icon/flowery")
        local icon_mini = Assets.getTexture("party/flowery/menu/icon/flowery_mini")
        Draw.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Floweriness:", x, y, 0, 0.8, 1)

        Draw.draw(icon_mini, x+135, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+150, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+165, y+6, 0, 2, 2)
        return true
    elseif index == 3 then
        local icon = Assets.getTexture("ui/menu/icon/flowery")
        local icon_mini = Assets.getTexture("party/flowery/menu/icon/flowery_mini")
        Draw.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Guts:", x, y, 0, 1, 1)

        Draw.draw(icon_mini, x+95, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+110, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+125, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+140, y+6, 0, 2, 2)
        Draw.draw(icon_mini, x+155, y+6, 0, 2, 2)
        return true
    end
end

return character