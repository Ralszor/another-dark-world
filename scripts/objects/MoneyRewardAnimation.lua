---@class MoneyRewardAnimation : Object
local MoneyRewardAnimation, super = Class(Object)

local PANEL_X = 28
local PANEL_Y = 425
local PANEL_WIDTH = 135
local PANEL_HEIGHT = 52

local SOUL_COLORS = {
    COLORS.red,
    COLORS.blue,
    COLORS.purple,
    COLORS.green,
}

local function statusStacks(flag)
    local value = Game:getFlag(flag, 0)
    if value == true then return 1 end
    return math.max(0, math.floor(tonumber(value) or 0))
end

local function printOutlined(text, x, y, color)
    Draw.setColor(COLORS.black)
    love.graphics.print(text, x - 1, y)
    love.graphics.print(text, x + 1, y)
    love.graphics.print(text, x, y - 1)
    love.graphics.print(text, x, y + 1)
    Draw.setColor(color or COLORS.white)
    love.graphics.print(text, x, y)
end

function MoneyRewardAnimation:init(source_x, source_y, next_battle)
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self:setParallax(0, 0)
    self.layer = WORLD_LAYERS["textbox"]

    self.source_x = source_x
    self.source_y = source_y
    self.next_battle = next_battle
    self.reward = Mod:getUpcomingMoneyRemaining(next_battle)
    self.texture = Assets.getTexture("ui/dollar")
    self.particles = {}
    self.timer = 0
    self.spawned = 0
    self.arrived = 0
    self.finished = self.reward <= 0
    self.hud_progress = 0
    self.stat_box = StatBox({}, PANEL_X, PANEL_Y)
end

function MoneyRewardAnimation:drawStatBoxHUD()
    local member, health, maximum, tension, soul_color = self:getPartyData()
    local eased = 1 - ((1 - self.hud_progress) ^ 3)
    local panel_y = PANEL_Y + ((1 - eased) * 34)
    local alpha = eased
    self.stat_box.x, self.stat_box.y = PANEL_X, panel_y
    self.stat_box:setData({member = member, name = member and member:getName() or "PLAYER", health = health, max_health = maximum, tension = tension, money = Mod:getLocalMoney(), active = true})
    self.stat_box:setOptions({alpha = alpha, show_tension = true})
    self.stat_box:fullDraw()
    local token = Token.DEFINITIONS[Mod:getToken()] or Token.DEFINITIONS.heart
    local token_color = token == Token.DEFINITIONS.heart and soul_color or COLORS.white
    Draw.setColor(token_color[1], token_color[2], token_color[3], alpha)
    Draw.draw(Assets.getTexture("ui/token/" .. token.texture), PANEL_X + PANEL_WIDTH - 20, panel_y + 10)
    self:drawStatus("ui/statuses/friend", statusStacks("anotherdoor_bite_status"), 1, panel_y)
    self:drawStatus("ui/statuses/salve", statusStacks("anotherdoor_poison_status"), 2, panel_y)
end

function MoneyRewardAnimation:isDone()
    return self.finished
end

function MoneyRewardAnimation:spawnMoney()
    self.spawned = self.spawned + 1
    table.insert(self.particles, {
        age = 0,
        arrived = false,
        offset_x = ((self.spawned - 1) % 3 - 1) * 8,
    })
end

function MoneyRewardAnimation:update()
    self.timer = self.timer + DT
    self.hud_progress = MathUtils.clamp(self.timer / 0.25, 0, 1)

    if self.timer >= 0.3 then
        local should_have_spawned = math.min(
            self.reward,
            math.floor((self.timer - 0.3) / 0.16) + 1
        )
        while self.spawned < should_have_spawned do
            self:spawnMoney()
        end
    end

    for _, particle in ipairs(self.particles) do
        particle.age = particle.age + DT
        if not particle.arrived and particle.age >= 0.62 then
            particle.arrived = true
            self.arrived = self.arrived + 1
            if Mod:claimUpcomingMoney(self.next_battle) then
                Assets.playSound("item")
            end
        end
    end

    if self.arrived >= self.reward
        and self.timer >= 0.3 + ((math.max(self.reward, 1) - 1) * 0.16) + 0.82
    then
        self.finished = true
    end

    super.update(self)
end

function MoneyRewardAnimation:getPartyData()
    local member = Game.party[1]
    local health = member and member:getHealth() or 0
    local maximum = member and member:getStat("health") or 1
    local tension = member and member.tension or {value = 0, max = 100}
    local party_number = math.max(1, math.floor(tonumber((Mod:getLocalPartyNumber())) or 1))
    return member, health, maximum, tension, SOUL_COLORS[party_number] or COLORS.red
end

function MoneyRewardAnimation:drawStatus(texture_path, stacks, slot, panel_y)
    if stacks <= 0 then return end
    local texture = Assets.getTexture(texture_path)
    local x = PANEL_X + 6 + ((slot - 1) * 24)
    local y = panel_y - 42
    Draw.setColor(COLORS.white)
    Draw.draw(texture, x, y)

    local font = Assets.getFont("tenna", 8)
    local text = tostring(stacks)
    love.graphics.setFont(font)
    printOutlined(text, x + 20 - font:getWidth(text), y + 20 - font:getHeight(), COLORS.white)
end

function MoneyRewardAnimation:drawMoney()
    local target_x = PANEL_X + PANEL_WIDTH - 14
    local target_y = PANEL_Y + PANEL_HEIGHT - 8
    for _, particle in ipairs(self.particles) do
        if not particle.arrived then
            local x, y, scale
            if particle.age < 0.16 then
                local progress = MathUtils.clamp(particle.age / 0.16, 0, 1)
                x = self.source_x + particle.offset_x
                y = self.source_y - (26 * (1 - ((1 - progress) ^ 3)))
                scale = 0.5 + (progress * 0.7)
            else
                local progress = MathUtils.clamp((particle.age - 0.16) / 0.46, 0, 1)
                local eased = progress * progress * (3 - (2 * progress))
                x = MathUtils.lerp(self.source_x + particle.offset_x, target_x, eased)
                y = MathUtils.lerp(self.source_y - 26, target_y, eased)
                scale = MathUtils.lerp(1.2, 0.65, eased)
            end
            Draw.setColor(COLORS.white)
            Draw.draw(
                self.texture,
                x,
                y,
                0,
                scale,
                scale,
                self.texture:getWidth() / 2,
                self.texture:getHeight() / 2
            )
        end
    end
end

function MoneyRewardAnimation:draw()
    self:drawStatBoxHUD()
    self:drawMoney()
    super.draw(self)
end

return MoneyRewardAnimation
