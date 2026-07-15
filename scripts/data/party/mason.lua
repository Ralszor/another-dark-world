local character, super = Class(PartyMember, "mason")

function character:init()
    super.init(self)

    self.name = "Mason"

    self:setActor("mason")

    self.level = 1
    self.title = "Gunslinger\nhates the\nbelch.plorgius"

    self.soul_priority = 1
    self.soul_color = {1, 106/255, 0}
    self.soul_facing = "up"
    
    self.has_spells = true

    self.has_xact = true
    self.xact_name = "M-ACT"

    self.lw_portrait = "face/mason/neutral"

    self.health = 100
    self.mana = 15

    self.stats = {
        health = 100,
        attack = 10,
        defense = 2,
        magic = 3,
        mana = 30
    }

    self.weapon_icon = "ui/menu/equip/sword"

    self:setWeapon("winglade")

    self.lw_weapon_default = "light/pencil"
    self.lw_armor_default = "light/bandage"

    self.color = ColorUtils.hexToRGB("fdc748")
    self.dmg_color = nil
    self.attack_bar_color = {0.5, 0.5, 0}
    self.attack_box_color = {127/255, 106/255, 0}
    self.xact_color = nil
	-- highlight color A
    self.highlight_color = ColorUtils.hexToRGB("#7F6A00FF")
		-- highlight color B
    self.highlight_color_alt = ColorUtils.hexToRGB("#7F0000FF")

    self.menu_icon = "party/mason/head"
    self.head_icons = "party/mason/icon"
    self.name_sprite = "party/mason/name"

    self.attack_sprite = "effects/attack/mash"
    self.attack_sound = "laz_c"
    self.attack_pitch = 1

    self.battle_offset = {2, 1}
    self.head_icon_offset = {0, -3}
    self.menu_icon_offset = nil
end

function character:onLevelUp(level)
    self:increaseStat("health", 2)
    if level % 10 == 0 then
        self:increaseStat("attack", 1)
    end
end

function character:onLevelUpLVLib(level)
    self:increaseStat("health", 5)
    self:increaseStat("attack", 1)
    if level % 2 == 0 then
        self:increaseStat("defense", 1)
        self:increaseStat("magic", 1)
    end
end

function character:drawPowerStat(index, x, y, menu)
    if index == 1  then
        local icon = Assets.getTexture("ui/menu/icon/demon")
        love.graphics.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Skills", x, y, 0, 0.7, 1)
        love.graphics.print("Yes", x+130, y)
        return true
    elseif index == 2 then
        local icon = Assets.getTexture("ui/menu/icon/magic")
        love.graphics.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Father", x, y)
        love.graphics.print("Yes", x+130, y, 0)
        return true
    elseif index == 3 then
        local icon = Assets.getTexture("ui/menu/icon/fire")
        love.graphics.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Guts:", x, y)

        love.graphics.draw(icon, x+90, y+6, 0, 2, 2)
        love.graphics.print("x", x+111, y)
        love.graphics.print("∞", x+122, y+3)

        return true
    end
end

function character:getGameOverMessage(main)
    return {
        "Hey, I believe we\ncan do this.",
        main:getName()..",[wait:5]\nlet's try again!"
    }
end

function character:autoHealSwoonAmount()
    return 1
    -- If needed, I'll safeguard this, but I don't see that as necessary.
end

return character
