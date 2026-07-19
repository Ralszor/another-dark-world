---@class Token : Object
local Token, super = Class(Object)

local TOOLTIP_WIDTH = 245

Token.DEFINITIONS = {
    heart = {name = "Heart", texture = "heart"},
    refused = {
        name = "It refused",
        texture = "refused",
        description = "Your max HP is now 50. Once per round, fatal damage resurrects you with 50 HP.",
    },
    prophet = {
        name = "Prophet",
        texture = "prophet",
        description = "Your Max HP is now 150. Each time you recieve money, you recieve half.",
    },
    lovers_l = {
        name = "Two Sides Of A Switch",
        texture = "lovers_L",
        description = "When both sides pick the same card, heal 3 HP. If the other side leaves or dies, take 100 damage.",
    },
    lovers_r = {
        name = "Two Sides Of A Switch",
        texture = "lovers_R",
        description = "When both sides pick the same card, heal 3 HP. If the other side cashes out or leaves, take 100 damage.",
    },
    unveil = {
        name = "Final Prophecy Unveils",
        texture = "unveil",
        description = "If you hold this token, you can see everybody else's TP.",
    },
    equip = {
        name = "Equip",
        texture = "equip",
        description = "Each time you take damage, you receive 10% of it as TP.",
    },
}

function Token:init(battle, member_key, token_id, color)
    super.init(self, 0, 0, 16, 16)
    self.battle = battle
    self.member_key = member_key
    self.hovered = false
    self.visible = false
    self.token_color = color or COLORS.white
    self:setToken(token_id or "heart")
end

function Token:setToken(token_id)
    local definition = self.DEFINITIONS[token_id]
    assert(definition, "Unknown token: " .. tostring(token_id))
    self.token_id = token_id
    self.definition = definition
    self.texture = Assets.getTexture("ui/token/" .. definition.texture)
    self.width = self.texture:getWidth()
    self.height = self.texture:getHeight()
    self.hovered = false
end

function Token:setTokenColor(color)
    self.token_color = color or COLORS.white
end

-- Optional extension hooks for token-specific objects.
function Token:onEquip() end
function Token:onUnequip() end
function Token:onTurnStart() end
function Token:onFatalDamage() end
function Token:onMoneyReceived(amount)
    return amount
end

function Token:updatePosition()
    local member, index = self.battle:getNetworkMemberByKey(self.member_key)
    if not member or member.active == false then
        self.visible = false
        return
    end

    local panel_x = self.battle:getNetworkPanelX(index)
    local start_x = panel_x + self.battle:getNetworkPanelWidth() - 20
    local start_y = self.battle:getNetworkPanelY() + 10
    local phase = self.battle.card_phase

    if phase == "CHOOSING" then
        self.x = start_x
        self.y = start_y
        self.visible = true
    elseif (phase == "REVEAL" or phase == "RESOLVING" or phase == "RESOLVED")
        and self.battle.card_selections[self.member_key]
    then
        local progress = phase == "RESOLVED" and 1 or self.battle.card_reveal_progress
        progress = 1 - ((1 - progress) ^ 3)
        local target_x, target_y = self.battle:getCardTokenTarget(member, self.width)
        self.x = MathUtils.lerp(start_x, target_x, progress)
        self.y = MathUtils.lerp(start_y, target_y, progress)
        self.visible = true
    else
        self.visible = false
    end
    self.alpha = self.battle.card_cards_alpha or 1
end

function Token:update()
    self:updatePosition()
    if self.visible and self.definition.description then
        local mouse_x, mouse_y = Input.getMousePosition()
        self.hovered = mouse_x >= self.x and mouse_x < self.x + self.width
            and mouse_y >= self.y and mouse_y < self.y + self.height
    else
        self.hovered = false
    end
    super.update(self)
end

function Token:drawTooltip()
    local tooltip_x = 23
    if self.x + tooltip_x + TOOLTIP_WIDTH > SCREEN_WIDTH then
        tooltip_x = -(TOOLTIP_WIDTH + 7)
    end
    local tooltip_y = -23
    local tooltip_height = 64

    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", tooltip_x, tooltip_y, TOOLTIP_WIDTH, tooltip_height, 3, 3)
    Draw.setColor(COLORS.white)
    love.graphics.rectangle("line", tooltip_x, tooltip_y, TOOLTIP_WIDTH, tooltip_height, 3, 3)

    love.graphics.setFont(Assets.getFont("main", 16))
    Draw.setColor(COLORS.yellow or COLORS.white)
    love.graphics.print(self.definition.name, tooltip_x + 7, tooltip_y + 4)
    love.graphics.setFont(Assets.getFont("tenna", 8))
    Draw.setColor(COLORS.white)
    love.graphics.printf(
        self.definition.description,
        tooltip_x + 7,
        tooltip_y + 24,
        TOOLTIP_WIDTH - 14,
        "left"
    )
end

function Token:draw()
    Draw.setColor(self.token_id == "heart" and self.token_color or COLORS.white)
    Draw.draw(self.texture, 0, 0)
    if self.hovered then
        self:drawTooltip()
    end
    super.draw(self)
end

return Token
