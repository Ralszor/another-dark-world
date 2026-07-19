local character, super = Class(PartyMember, "cress")

function character:init()
    super.init(self)

    self.name = "Cress"

    self:setActor("cress")

    self.level = 94
    self.title = "Battlemage\nProtects his friends."

    self.soul_priority = 1
    self.soul_color = ColorUtils.hexToRGB("#9800FF")
    self.soul_facing = "down"

    if Game:getFlag("jamm_canact") then
        self.has_act = true
		-- self.soul_priority = 10
    else
        self.has_act = false
    end
    self.has_spells = true

    self.has_xact = true
    self.xact_name = "COMMAND"

    self.lw_portrait = "face/jamm/neutral"

    self:addSpell("supersling")
    self:addSpell("darksling")
    self:addSpell("numbshot")

    self.health = 120
    self.mana = 15

    self.stats = {
        health = 120,
        attack = 10,
        defense = 2,
        magic = 3,
        mana = 30
    }

    self.weapon_icon = "ui/menu/equip/sling"

    self:setWeapon("basic_sling")

    self.lw_weapon_default = "light/rope_sling"
    self.lw_armor_default = "light/bandage"

    self.color = ColorUtils.hexToRGB("#9800FF")
    self.dmg_color = ColorUtils.hexToRGB("#9800FF")
    self.attack_bar_color = ColorUtils.hexToRGB("#9800FF")
    self.attack_box_color = ColorUtils.hexToRGB("#9800FF")
    self.xact_color = ColorUtils.hexToRGB("#9800FF")
	-- highlight color A
    self.highlight_color = ColorUtils.hexToRGB("#9800FF")
		-- highlight color B
    self.highlight_color_alt = ColorUtils.hexToRGB("#9800FF")

    self.menu_icon = "party/cress/head"
    self.head_icons = "party/cress/icon"
    self.name_sprite = "party/cress/name"

    self.attack_sprite = "effects/attack/sling"
    self.attack_sound = "sling"
    self.attack_pitch = 1

    self.battle_offset = {2, 1}
    self.head_icon_offset = {0, -5}
    self.menu_icon_offset = {0, -10}
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
