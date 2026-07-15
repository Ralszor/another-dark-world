local actor, super = Class(Actor, "flowery")

function actor:init()
    -- Display name (optional)
    self.name = "Flowery"

    -- Width and height for this actor, used to determine its center
    self.width = 20
    self.height = 38

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {0, 25, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 1, 0}

    self.soul_offset = {11, 11}

    -- Path to this actor's sprites (defaults to "")
    self.path = "party/flowery"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "walk"

    -- Sound to play when this actor speaks (optional)
    self.voice = nil

    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {
        -- Battle animations
        ["battle/idle"]         = {"battle/idle", 1/3, true},

        ["battle/attack"]       = {"battle/attack", 1/3, false},
        ["battle/act"]          = {"battle/act", 1/3, false},
        ["battle/spell"]        = {"battle/spell", 1/9, false, next="battle/idle"},
        ["battle/item"]         = {"battle/item", 1/3, false, next="battle/idle"},
        ["battle/spare"]        = {"battle/spare", 1/3, false},

        ["battle/attack_ready"] = {"battle/attackready", 1/6, true},
        ["battle/act_ready"]    = {"battle/actready", 1/6, true},
        ["battle/spell_ready"]  = {"battle/spellready", 1/6, true},
        ["battle/item_ready"]   = {"battle/itemready", 1/6, true},
        ["battle/defend_ready"] = {"battle/defend", 1/15, false},

        ["battle/act_end"]      = {"battle/actend", 1/15, false},

        ["battle/hurt"]         = {"battle/hurt", 1/15, false, temp=true, duration=0.5},
        ["battle/defeat"]       = {"battle/defeat", 1/15, false},
        ["battle/swooned"]      = {"battle/swoon", 1/15, false},

        ["battle/transition"]   = {"battle/idle", 1/15, false},
        ["battle/victory"]      = {"battle/victory", 1/10, false},
        ["battle/transition_out"] = {"battle/transition_out", 1/15, false},
    }
    self.flip_sprites = {}

    -- Tables of sprites to change into in mirrors
    self.mirror_sprites = {
        ["walk/down"] = "walk/up",
        ["walk/up"] = "walk/down",
        ["walk/left"] = "walk/left",
        ["walk/right"] = "walk/right",
    }

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {
        -- Movement offsets
        ["walk/down"] = {0, -22},
        ["walk/left"] = {0, -22},
        ["walk/right"] = {0, -22},
        ["walk/up"] = {0, -22},

        -- Battle offsets
        ["battle/idle"] = {0, -22},

        ["battle/attack"] = {0, -22},
        ["battle/attackready"] = {0, -22},
        ["battle/act"] = {0, -22},
        ["battle/actend"] = {0, -22},
        ["battle/actready"] = {0, -22},
        ["battle/spell"] = {-2, -28},
        ["battle/spellready"] = {0, -14},
        ["battle/item"] = {0, -22},
        ["battle/itemready"] = {0, -22},
        ["battle/spare"] = {0, -11},
        ["battle/defend"] = {-11, -11},

        ["battle/defeat"] = {0, 0},
        ["battle/hurt"] = {0, -11}, -- does this exist? Bor's answer: yes, it does.
        ["battle/swoon"] = {0, -22}, -- does this exist? Bor's answer: yes, it does.

        ["battle/intro"] = {0, -22},
        ["battle/victory"] = {0, -22},
        ["battle/transition_out"] = {0, -22},
    }
end

return actor