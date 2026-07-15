local actor, super = Class(Actor, "mason")

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "masondevelops"

    -- Width and height for this actor, used to determine its center
    self.width = 23
    self.height = 30

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {3, 21, 17, 13}
	
    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {0.5, 1, 1}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "npcs/mason"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "walk"

    -- Sound to play when this actor speaks (optional)
    self.voice = "clover"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil
    --deviceuser0
    self.indent_string = "> "
    
    -- Whether this actor as a follower will blush when close to the player
    self.can_blush = false

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {
        ["idle"] = 0.2
    }

    -- Table of sprite animations
    self.animations = {}

    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {
        ["fell"] = {-3, 13};
        ["walk/down"] = {0, 0};
        ["walk/left"] = {1, 0};
        ["walk/right"] = {1, 0};
        ["walk/up"] = {0, 0};
    }
end

return actor