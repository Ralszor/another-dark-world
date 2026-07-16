---@class StatBox : Object
local StatBox, super = Class(Object)

StatBox.WIDTH = 135
StatBox.HEIGHT = 52

local function setColor(color, alpha)
    color = color or COLORS.white
    Draw.setColor(color[1], color[2], color[3], (color[4] or 1) * (alpha or 1))
end

local function printOutlined(text, x, y, color, scale, alpha)
    scale, alpha = scale or 1, alpha or 1
    Draw.setColor(0, 0, 0, alpha)
    love.graphics.print(text, x - 1, y, 0, scale, scale)
    love.graphics.print(text, x + 1, y, 0, scale, scale)
    love.graphics.print(text, x, y - 1, 0, scale, scale)
    love.graphics.print(text, x, y + 1, 0, scale, scale)
    setColor(color, alpha)
    love.graphics.print(text, x, y, 0, scale, scale)
end

function StatBox.getHeadTexture(data)
    local member = data and (data.chara or data.member)
    if not member or not member.getHeadIcons then return nil end
    local path = member:getHeadIcons()
    if not path then return nil end
    local success, texture = pcall(Assets.getTexture, path .. "/head")
    return success and texture or nil
end

function StatBox.getNameTexture(data)
    local member = data and (data.chara or data.member)
    if not member or not member.getNameSprite then return nil end
    local path = member:getNameSprite()
    if not path then return nil end
    local success, texture = pcall(Assets.getTexture, path)
    return success and texture or nil
end

function StatBox.getHealth(data)
    if not data then return nil end
    if data.resurrection_health ~= nil then
        return data.resurrection_health, data.resurrection_max_health or 50
    end
    if data.health ~= nil then return data.health, data.max_health end
    local source = data.battler
    if source and source.getHealth and source.getStat then
        return source:getHealth(), source:getStat("health")
    end
    local member = data.chara or data.member
    if member and member.getHealth and member.getStat then
        return member:getHealth(), member:getStat("health")
    end
end

function StatBox:init(data, x, y, options)
    super.init(self, x or 0, y or 0, self.WIDTH, self.HEIGHT)
    self.is_door_stat_box = true
    self.data = data or {}
    self.options = options or {}
end

function StatBox:setData(data) self.data = data or {} end
function StatBox:setOptions(options) self.options = options or {} end

function StatBox:drawTension(alpha)
    if self.options.show_tension == false then return end
    local tension = self.data.tension or {value = 0, max = 100}
    if type(tension) == "number" then
        tension = {value = tension, max = self.data.tension_max or 100}
    end
    local maximum = math.max(tonumber(tension.max) or 100, 1)
    local value = MathUtils.clamp(tonumber(tension.value) or 0, 0, maximum)
    local percentage, is_max = value / maximum, value >= maximum
    love.graphics.setFont(Assets.getFont("tenna", 8))
    setColor(is_max and PALETTE["tension_maxtext"] or PALETTE["tension_fill"], alpha)
    love.graphics.print(is_max and "TP: MAX" or ("TP: " .. math.floor(percentage * 100) .. "%"), 6, -13)
    setColor(PALETTE["tension_back"], alpha)
    love.graphics.rectangle("fill", 67, -14, self.WIDTH - 74, 9, 2, 2)
    setColor(is_max and PALETTE["tension_max"] or PALETTE["tension_fill"], alpha)
    love.graphics.rectangle("fill", 67, -14, (self.WIDTH - 74) * percentage, 9, 2, 2)
end

function StatBox:draw()
    local data, options = self.data, self.options
    local alpha = options.alpha or 1
    local box_color = data.box_color or (data.member and data.member.getColor and {data.member:getColor()}) or COLORS.white
    if options.total ~= nil then
        love.graphics.setFont(Assets.getFont("tenna", 16))
        setColor(COLORS.white, alpha)
        love.graphics.print("TOTAL " .. tostring(options.total), 6, -68)
    end
    self:drawTension(alpha)
    if not options.selected then
        Draw.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, self.WIDTH, self.HEIGHT)
        setColor(box_color, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 1, 1, self.WIDTH - 2, self.HEIGHT - 2)
        love.graphics.rectangle("line", 1, 1, self.WIDTH - 2, -20)
        love.graphics.setLineWidth(1)
    end
    local head = self.getHeadTexture(data)
    if head then Draw.setColor(1, 1, 1, alpha); Draw.draw(head, 5, 7) end
    local health, maximum = self.getHealth(data)
    love.graphics.setFont(Assets.getFont("smallnumbers"))
    Draw.setColor(1, 1, 1, alpha); love.graphics.print("HP", 25, 2)
    setColor(COLORS.dkgray or {0.25, 0.25, 0.25}, alpha)
    love.graphics.rectangle("fill", 41, 16, 70, 8, 4, 4)
    if health and maximum and maximum > 0 then
        setColor(box_color, alpha)
        love.graphics.rectangle("fill", 41, 16, 70 * MathUtils.clamp(health / maximum, 0, 1), 8, 4, 4)
        local current = tostring(math.floor(health))
        printOutlined(current, 63, 8, COLORS.white, 1, alpha)
        printOutlined("/" .. tostring(math.floor(maximum)), 63 + love.graphics.getFont():getWidth(current) + 1, 12, COLORS.white, 0.5, alpha)
    else
        printOutlined("--", 63, 8, COLORS.gray, 1, alpha)
        printOutlined("/--", 63 + love.graphics.getFont():getWidth("--") + 1, 12, COLORS.gray, 0.5, alpha)
    end
    local name_texture = self.getNameTexture(data)
    Draw.setColor(1, 1, 1, alpha)
    if name_texture then
        local scale = math.min(1, (self.WIDTH - 30) / name_texture:getWidth(), (self.HEIGHT - 29) / name_texture:getHeight())
        Draw.draw(name_texture, 5, 32, 0, scale, scale)
    else
        love.graphics.setFont(Assets.getFont("main", 16))
        love.graphics.print(string.upper(tostring(data.name or "PLAYER")), 5, 32)
    end
    local font, money = Assets.getFont("tenna", 8), tostring(math.max(0, math.floor(tonumber(data.money) or 0)))
    love.graphics.setFont(font)
    printOutlined("D$", self.WIDTH - 6 - font:getWidth("D$"), self.HEIGHT - 25, COLORS.white, 1, alpha)
    printOutlined(money, self.WIDTH - 6 - font:getWidth(money), self.HEIGHT - 14, COLORS.white, 1, alpha)
    if data.active == false then
        Draw.setColor(0, 0, 0, 0.65 * alpha)
        love.graphics.rectangle("fill", 0, -20, self.WIDTH, self.HEIGHT + 20)
    end
    super.draw(self)
end

return StatBox
