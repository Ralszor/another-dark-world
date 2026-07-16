---@class ResurrectionNumber : Object
local ResurrectionNumber, super = Class(Object)

function ResurrectionNumber:init(x, y)
    super.init(self, x, y)
    self.is_door_damage_number = true
    self.text = "Resurrection"
    self.font = Assets.getFont("main", 16)
    self.timer = 0
    self.life = 2.25
    self.start_y = y
end

function ResurrectionNumber:update()
    self.timer = self.timer + DT
    local progress = MathUtils.clamp(self.timer / self.life, 0, 1)
    self.y = self.start_y - (52 * (1 - ((1 - progress) ^ 3)))
    if progress > 0.72 then
        self.alpha = 1 - ((progress - 0.72) / 0.28)
    end
    if progress >= 1 then
        self:remove()
        return
    end
    super.update(self)
end

function ResurrectionNumber:draw()
    love.graphics.setFont(self.font)
    local x = -self.font:getWidth(self.text) / 2
    local y = -self.font:getHeight() / 2
    Draw.setColor(0, 0, 0, self.alpha)
    love.graphics.print(self.text, x - 1, y)
    love.graphics.print(self.text, x + 1, y)
    love.graphics.print(self.text, x, y - 1)
    love.graphics.print(self.text, x, y + 1)
    Draw.setColor(1, 1, 0.45, self.alpha)
    love.graphics.print(self.text, x, y)
    super.draw(self)
end

return ResurrectionNumber
