---@class PoisonStatus : Object
local PoisonStatus, super = Class(Object)

local TOOLTIP_WIDTH = 245

function PoisonStatus:init(battle, stacks, member_key)
    super.init(self, 0, 0, 20, 20)
    self.battle = battle
    self.member_key = member_key
    self.texture = Assets.getTexture("ui/statuses/salve")
    self.stacks = 0
    self.acquiring = false
    self.hovered = false
    self.pop_time = 0.18
    self.slide_time = 0.55
    self.timer = 0
    self:setStacks(stacks)
    self:setTargetPosition()
end

function PoisonStatus:setTargetPosition()
    local x, y = self.battle:getDoorStatusTarget(self.member_key, 2)
    self.target_x = x
    self.target_y = y
    if not self.acquiring then
        self.x = x
        self.y = y
    end
end

function PoisonStatus:beginAcquire(x, y)
    self.start_x = x
    self.start_y = y
    self.x = x
    self.y = y
    self.timer = 0
    self.acquiring = true
    self.visible = true
    self.hovered = false
end

function PoisonStatus:setStacks(stacks)
    self.stacks = math.max(0, math.floor(tonumber(stacks) or 0))
    self.visible = self.stacks > 0 or self.acquiring
    if not self.visible then self.hovered = false end
end

function PoisonStatus:update()
    self:setTargetPosition()

    if self.acquiring then
        self.timer = self.timer + DT
        if self.timer < self.pop_time then
            local progress = self.timer / self.pop_time
            self.x = self.start_x
            self.y = self.start_y - (28 * (1 - ((1 - progress) ^ 3)))
        else
            local progress = MathUtils.clamp(
                (self.timer - self.pop_time) / self.slide_time,
                0,
                1
            )
            local eased = progress * progress * (3 - (2 * progress))
            self.x = MathUtils.lerp(self.start_x, self.target_x, eased)
            self.y = MathUtils.lerp(self.start_y - 28, self.target_y, eased)
            if progress >= 1 then
                self.acquiring = false
                self.x = self.target_x
                self.y = self.target_y
                self.visible = self.stacks > 0
            end
        end
    end

    if self.visible and not self.acquiring then
        local mouse_x, mouse_y = Input.getMousePosition()
        self.hovered = mouse_x >= self.x and mouse_x < self.x + self.width
            and mouse_y >= self.y and mouse_y < self.y + self.height
    else
        self.hovered = false
    end
    super.update(self)
end

function PoisonStatus:drawStackCount()
    local font = Assets.getFont("tenna", 8)
    local text = tostring(self.stacks)
    local x = self.width - font:getWidth(text)
    local y = self.height - font:getHeight()
    love.graphics.setFont(font)
    Draw.setColor(COLORS.black)
    love.graphics.print(text, x - 1, y)
    love.graphics.print(text, x + 1, y)
    love.graphics.print(text, x, y - 1)
    love.graphics.print(text, x, y + 1)
    Draw.setColor(COLORS.white)
    love.graphics.print(text, x, y)
end

function PoisonStatus:draw()
    Draw.setColor(COLORS.white)
    Draw.draw(self.texture, 0, 0)
    self:drawStackCount()

    if self.hovered then
        local tooltip_x = 27
        if self.x + tooltip_x + TOOLTIP_WIDTH > SCREEN_WIDTH then
            tooltip_x = -(TOOLTIP_WIDTH + 7)
        end
        local tooltip_y = -23
        local tooltip_height = 60
        Draw.setColor(COLORS.black)
        love.graphics.rectangle("fill", tooltip_x, tooltip_y, TOOLTIP_WIDTH, tooltip_height, 3, 3)
        Draw.setColor(COLORS.white)
        love.graphics.rectangle("line", tooltip_x, tooltip_y, TOOLTIP_WIDTH, tooltip_height, 3, 3)
        love.graphics.setFont(Assets.getFont("main", 16))
        Draw.setColor(COLORS.yellow or COLORS.white)
        love.graphics.print("POISON", tooltip_x + 7, tooltip_y + 4)
        love.graphics.setFont(Assets.getFont("tenna", 8))
        Draw.setColor(COLORS.white)
        love.graphics.printf(
            "Take exact damage equal to your POISON stacks each turn.",
            tooltip_x + 7,
            tooltip_y + 24,
            TOOLTIP_WIDTH - 14,
            "left"
        )
    end
    super.draw(self)
end

return PoisonStatus
