---@class TensionNumber : Object
local TensionNumber, super = Class(Object)

function TensionNumber:init(amount, x, y)
    super.init(self, x, y)

    -- Battle draws panel numbers after the custom party strip.
    self.is_door_damage_number = true
    self.text = tostring(math.max(0, math.floor(math.abs(amount))))
    self.font = Assets.getFont("bignumbers")

    self.start_x = x
    self.start_y = y
    local angle = -math.pi / 2 + math.rad(love.math.random(-45, 45))
    local distance = love.math.random(42, 58)
    self.offset_x = math.cos(angle) * distance
    self.offset_y = math.sin(angle) * distance

    self.timer = 0
    self.slide_time = 3
    self.fade_time = 0.35
end

function TensionNumber:update()
    self.timer = self.timer + DT

    local slide = MathUtils.clamp(self.timer / self.slide_time, 0, 1)
    local eased = 1 - ((1 - slide) ^ 3)
    self.x = self.start_x + (self.offset_x * eased)
    self.y = self.start_y + (self.offset_y * eased)

    if self.timer > self.slide_time then
        self.alpha = 1 - MathUtils.clamp(
            (self.timer - self.slide_time) / self.fade_time,
            0,
            1
        )
    end

    if self.timer >= self.slide_time + self.fade_time then
        self:remove()
        return
    end

    super.update(self)
end

function TensionNumber:draw()
    love.graphics.setFont(self.font)
    Draw.setColor(1, 0.55, 0, self.alpha)
    love.graphics.print(
        self.text,
        -self.font:getWidth(self.text) / 2,
        -self.font:getHeight() / 2
    )
    super.draw(self)
end

return TensionNumber
