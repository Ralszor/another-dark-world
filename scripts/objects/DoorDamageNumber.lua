---@class DoorDamageNumber : Object
local DoorDamageNumber, super = Class(Object)

function DoorDamageNumber:init(amount, x, y, healing)
    super.init(self, x, y)

    self.is_door_damage_number = true
    self.text = tostring(math.max(0, math.floor(math.abs(amount))))
    self.font = Assets.getFont("damage-door")
    self.healing = healing

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

function DoorDamageNumber:update()
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

function DoorDamageNumber:draw()
    love.graphics.setFont(self.font)
    if self.healing then
        Draw.setColor(0.3, 1, 0.3, self.alpha)
    else
        Draw.setColor(1, 0.25, 0.25, self.alpha)
    end

    love.graphics.print(
        self.text,
        -self.font:getWidth(self.text) / 2,
        -self.font:getHeight() / 2
    )
    super.draw(self)
end

return DoorDamageNumber
