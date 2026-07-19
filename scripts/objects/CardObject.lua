---@class CardObject : Object
local CardObject, super = Class(Object)

local ACTION_BOX_WIDTH, ACTION_BOX_HEIGHT = 70, 22

function CardObject:init(battle, card, index, x, y)
    self.texture = Assets.getTexture("card")
    super.init(self, x or 0, y or 0, self.texture:getWidth(), self.texture:getHeight())
    self.is_door_card = true
    self.battle, self.card, self.index = battle, card, index
end

function CardObject:setCard(card, index) self.card, self.index = card, index end
function CardObject:getHitHeight() return self.height + (self.card.party_action and ACTION_BOX_HEIGHT or 0) end
function CardObject:containsPoint(x, y)
    return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self:getHitHeight()
end

function CardObject:draw()
    local battle, card = self.battle, self.card
    local alpha = battle.card_cards_alpha or 1
    local selectable = battle:isCardSelectable(self.index)
    local card_alpha = selectable and alpha or alpha * 0.4
    local local_choice = battle.card_selections.__local
    Draw.setColor(1, 1, 1, card_alpha); Draw.draw(self.texture, 0, 0)
    if battle.card_phase == "CHOOSING" and not local_choice and battle.card_selection == self.index then
        local highlight = selectable and (COLORS.yellow or COLORS.white) or COLORS.gray or COLORS.grey or COLORS.white
        Draw.setColor(highlight[1], highlight[2], highlight[3], alpha)
        love.graphics.setLineWidth(2); love.graphics.rectangle("line", -3, -3, self.width + 6, self.height + 6, 4, 4); love.graphics.setLineWidth(1)
    end
    Draw.setColor(1, 1, 1, card_alpha)
    love.graphics.setFont(Assets.getFont("tenna", 8)); love.graphics.printf(card:getName(), 8, 14, self.width - 8, "center")
    love.graphics.setFont(Assets.getFont("main", 16)); love.graphics.printf(card:getEffect(), 3, math.floor(self.height / 2), self.width - 5, "center")
    local tp_cost = tonumber(card.tp_cost)
    if card.party_action and tp_cost and tp_cost > 0 then
        local font = Assets.getFont("tenna", 8)
        love.graphics.setFont(font)
        local tp_color = PALETTE["tension_fill"] or COLORS.orange or COLORS.white
        Draw.setColor(tp_color[1], tp_color[2], tp_color[3], card_alpha)
        love.graphics.printf(
            "TP " .. tostring(math.floor(tp_cost)),
            0,
            self.height - font:getHeight() - 4,
            self.width,
            "center"
        )
    end
    if card.party_action then
        local bx, by = (self.width - ACTION_BOX_WIDTH) / 2, self.height - 1
        Draw.setColor(0, 0, 0, alpha); love.graphics.rectangle("fill", bx, by, ACTION_BOX_WIDTH, ACTION_BOX_HEIGHT, 3, 3)
        Draw.setColor(1, 1, 1, card_alpha); love.graphics.rectangle("line", bx, by, ACTION_BOX_WIDTH, ACTION_BOX_HEIGHT, 3, 3)
        local member = battle:getLocalNetworkMember(); local color = member and member.box_color or COLORS.white
        Draw.setColor(color[1], color[2], color[3], card_alpha)
        love.graphics.setFont(Assets.getFont("main", 16)); love.graphics.printf(battle:getActionCardLabel(), bx, by + 2, ACTION_BOX_WIDTH, "center")
    end
    super.draw(self)
end

return CardObject
