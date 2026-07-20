local SpireActor, super = Class(Actor, "spire")

function SpireActor:init()
    super.init(self)

    self.name = "Spire"
    self.width = 40
    self.height = 40
    self.hitbox = {0, 0, 40, 40}
    self.color = COLORS.yellow
    self.path = "event"
    self.default = "idle"

    self.animations = {
        ["idle"] = {"top", 1, false, frames = {1}},
        ["top"] = {"top", 0.08, false, next = "idle"},
    }
    self.offsets = {
        ["idle"] = {0, 0},
        ["top"] = {0, 0},
    }
end

return SpireActor
