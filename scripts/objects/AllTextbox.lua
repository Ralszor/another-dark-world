---@class AllTextbox : Object
local AllTextbox, super = Class(Object)

local BOX_X, BOX_Y = 32, 22
local BOX_WIDTH, BOX_HEIGHT = SCREEN_WIDTH - 64, 118

function AllTextbox:init(battle, serial, text)
    super.init(self, BOX_X, BOX_Y, BOX_WIDTH, BOX_HEIGHT)
    self.battle = battle
    self.serial = serial
    self.is_all_textbox = true
    self.layer = BATTLE_LAYERS["top"] + 20

    self.textbox = Textbox(0, 0, BOX_WIDTH, BOX_HEIGHT)
    self.textbox:setSkippable(true)
    self.textbox:setAdvance(true)
    self.textbox:setText(text, function()
        self.battle:confirmAllText(self.serial)
    end)
    self:addChild(self.textbox)
end

function AllTextbox:draw()
    super.draw(self)

    local members = self.battle.network_party or {}
    local heart = Assets.getTexture("ui/token/heart")
    local spacing = heart:getWidth() + 5
    local start_x = self.width - 10 - (#members * spacing)
    local y = self.height - heart:getHeight() - 8
    for index, member in ipairs(members) do
        local key = self.battle:getNetworkSelectionKey(member)
        local ready = self.battle:isAllTextMemberReady(self.serial, key)
        local color = member.soul_color or COLORS.white
        Draw.setColor(color[1], color[2], color[3], ready and 1 or 0.3)
        Draw.draw(heart, start_x + ((index - 1) * spacing), y)
    end
end

return AllTextbox
