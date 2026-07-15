local squaresBG, super = Class(Object)

function squaresBG:init()
    super.init(self)
    self.sprite = self:addChild(Sprite("square"))
    self.sprite.wrap_texture_x = true
    self.sprite.wrap_texture_y = true
    self.sprite.physics.speed_x = -1
end

function squaresBG:update()
    super.update(self)
end

return squaresBG