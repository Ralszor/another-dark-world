local character, super = Class(PartyMember)

function character:init()
    super.init(self)

    self.name = "Vessel"

    self:setActor("vessel")
    self.level = Game.chapter
    self.title = "Strategist\nCommands with\nreasoning."
    self.soul_priority = 2
    self.soul_color = {1, 0, 0}

    self.has_act = true
    self.has_spells = false

    self.has_xact = false
    self.xact_name = "V-Action"

        --Set stats
        self.health = 120

    -- Base stats (saved to the save file)
        self.stats = {
            health = 120,
            attack = 12,
            defense = 2,
            magic = 0
        }
    -- Max stats from level-ups
        self.max_stats = {
            health = 160,
            attack = 14,
        }
    -- Party members which will also get stronger when this character gets stronger, even if they're not in the party
    self.stronger_absent = {"susie","noelle"}

    self.weapon_icon = "ui/menu/equip/sword"

    self.lw_weapon_default = "light/pencil"
    self.lw_armor_default = "light/bandage"

    -- Character color (for action box outline and hp bar)
    self.color = {0.85, 0.85, 0.85}
    -- Damage color (for the number when attacking enemies) (defaults to the main color)
    self.dmg_color = {0.9, 0.9, 0.9}
    -- Attack bar color (for the target bar used in attack mode) (defaults to the main color)
    self.color = {0.85, 0.85, 0.85}
    -- Attack box color (for the attack area in attack mode) (defaults to darkened main color)
    self.attack_box_color = {0.6, 0.6, 0.6}
    -- X-Action color (for the color of X-Action menu items) (defaults to the main color)
    self.xact_color = {0.5, 1, 1}

    -- Head icon in the equip / power menu
    self.menu_icon = "party/vessel/head"
    -- Path to head icons used in battle
    self.head_icons = "party/vessel/icon"
    -- Name sprite
    self.name_sprite = "party/vessel/name"

    -- Effect shown above enemy after attacking it
    self.attack_sprite = "effects/attack/staff"
    -- Sound played when this character attacks
    self.attack_sound = "laz_c"
    -- Pitch of the attack sound
    self.attack_pitch = 1

    -- Battle position offset (optional)
    self.battle_offset = {2, 1}
    -- Head icon position offset (optional)
    self.head_icon_offset = nil
    -- Menu icon position offset (optional)
    self.menu_icon_offset = nil

    -- Message shown on gameover (optional)
    self.gameover_message = nil
end

function character:onLevelUp(level)
    self:increaseStat("health", 2)
    if level % 10 == 0 then
        self:increaseStat("attack", 1)
    end
end

function character:onPowerSelect(menu)
    if Utils.random() < ((Game.chapter == 1) and 0.02 or 0.04) then
        menu.kris_dog = true
    else
        menu.kris_dog = false
    end
end

function character:drawPowerStat(index, x, y, menu)
    if index == 1 and menu.kris_dog then
        local frames = Assets.getFrames("misc/dog_sleep")
        local frame = math.floor(Kristal.getTime()) % #frames + 1
        love.graphics.print("Dog:", x, y)
        Draw.draw(frames[frame], x+120, y+5, 0, 2, 2)
        return true
    elseif index == 3 then
        local icon = Assets.getTexture("ui/menu/icon/fire")
        Draw.draw(icon, x-26, y+6, 0, 2, 2)
        love.graphics.print("Guts:", x, y)

        Draw.draw(icon, x+90, y+6, 0, 2, 2)
        if Game.chapter >= 2 then
            Draw.draw(icon, x+110, y+6, 0, 2, 2)
        end
        return true
    end
end

return character