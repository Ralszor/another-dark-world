---@class rune_rounds : Event
local rune_rounds, super = Class(Event)

function rune_rounds:init(x, y, shape)
    super.init(self, x, y, shape)
    self.rune = Sprite("world/rune")
    self.rune:setOrigin(0.5, 0.5)
    self.rune:setScale(2)
    self.rune:setPosition(self.width / 2, self.height / 2)
    self.recolor = self.rune:addFX(
        RecolorFX(1, 1, 1, 1),
        "double_effect"
    )
    self.siner = 0
    self:addChild(self.rune)
end

function rune_rounds:update()
    self.siner = self.siner + DT
    self.rune:setFrame(Mod:getRound())
    if Mod:isDoubleEffectActive() then
        local pulse = (math.sin(self.siner * 3) + 1) / 2
        local green_blue = MathUtils.lerp(1, 0.15, pulse)
        self.recolor:setColor(1, green_blue, green_blue, 1)
    else
        self.recolor:setColor(1, 1, 1, 1)
    end
    super.update(self)
end

return rune_rounds
