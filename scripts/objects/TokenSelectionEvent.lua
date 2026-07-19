---@class TokenSelectionEvent : Object
local TokenSelectionEvent, super = Class(Object)

local SCALE = 3
local FADE_SPEED = 2.5
local TOOLTIP_WIDTH = 245
local HIGHLIGHT_MIN_SCALE = SCALE + 0.25
local HIGHLIGHT_MAX_SCALE = SCALE + 0.5
local HIGHLIGHT_ORBIT_RADIUS = 5
local HIGHLIGHT_EASE_TIME = 1
local PICK_EFFECT_TIME = 0.4

local function easeOut(progress)
    return 1 - ((1 - progress) ^ 3)
end

local function shuffledTokenIDs(seed)
    local ids = {}
    for id in pairs(Token.DEFINITIONS) do
        if id ~= "heart" then table.insert(ids, id) end
    end
    table.sort(ids)
    local state = math.max(1, math.floor(tonumber(seed) or 1))
    for index = #ids, 2, -1 do
        state = (state * 48271) % 2147483647
        local other = (state % index) + 1
        ids[index], ids[other] = ids[other], ids[index]
    end
    while #ids > 6 do table.remove(ids) end
    return ids
end

function TokenSelectionEvent:init(battle, seed)
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.battle = battle
    self.seed = seed
    self.alpha = 0
    self.selection = 1
    self.enabled = false
    self.finished = false
    self.timer = 0
    self.highlight_timer = 0
    self.pick_timer = nil
    self.is_token_selection_event = true
    self.layer = BATTLE_LAYERS["top"] + 10
    self.options = {}

    local ids = shuffledTokenIDs(seed)
    local columns = math.ceil(#ids / 2)
    for index, id in ipairs(ids) do
        local definition = Token.DEFINITIONS[id]
        local texture = Assets.getTexture("ui/token/" .. definition.texture)

        local outline = Sprite("ui/token/" .. definition.texture)
        outline:setOrigin(0.5, 0.5)
        outline:setScale(SCALE)
        outline:addFX(OutlineFX(COLORS.white, {
            thickness = 1,
            cutout = true,
        }))
        self:addChild(outline)

        local outline_copy = Sprite("ui/token/" .. definition.texture)
        outline_copy:setOrigin(0.5, 0.5)
        outline_copy:setScale(SCALE)
        self:addChild(outline_copy)

        local sprite = Sprite("ui/token/" .. definition.texture)
        sprite:setOrigin(0.5, 0.5)
        sprite:setScale(SCALE)
        self:addChild(sprite)
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        local base_x = 90 + column * ((SCREEN_WIDTH - 180) / math.max(columns - 1, 1))
        local base_y = 205 + row * 105
        table.insert(self.options, {
            id = id,
            definition = definition,
            texture = texture,
            sprite = sprite,
            outline = outline,
            outline_copy = outline_copy,
            base_x = base_x,
            base_y = base_y,
            phase = ((seed + index * 47) % 628) / 100,
            speed = 0.35 + (((seed + index * 31) % 30) / 100),
        })
    end
end

function TokenSelectionEvent:setEnabled(enabled)
    self.enabled = enabled ~= false
end

function TokenSelectionEvent:getOptionPosition(option)
    local time = (self.battle.network_grid_time or 0) * option.speed + option.phase
    return option.base_x + math.cos(time) * 9, option.base_y + math.sin(time * 0.8) * 7
end

function TokenSelectionEvent:getHoveredOption()
    local mouse_x, mouse_y = Input.getMousePosition()
    for index, option in ipairs(self.options) do
        if not option.removed then
        local x, y = self:getOptionPosition(option)
        local w, h = option.texture:getWidth() * SCALE, option.texture:getHeight() * SCALE
        if mouse_x >= x - w / 2 and mouse_x < x + w / 2
            and mouse_y >= y - h / 2 and mouse_y < y + h / 2
        then
            return index
        end
        end
    end
end

function TokenSelectionEvent:setSelection(index, silent)
    if index == self.selection
        or not self.options[index]
        or self.options[index].removed
    then
        return
    end
    self.selection = index
    self.highlight_timer = 0
    if not silent then Assets.playSound("ui_move") end
end

function TokenSelectionEvent:moveSelection(step)
    for offset = 1, #self.options do
        local index = ((self.selection - 1 + (offset * step)) % #self.options) + 1
        if not self.options[index].removed then
            self:setSelection(index)
            return
        end
    end
end

function TokenSelectionEvent:onTokenPicked(token_id, member_key)
    for index, option in ipairs(self.options) do
        if option.id == token_id and not option.removed then
            local x, y = self:getOptionPosition(option)
            option.removed = true
            option.sprite:remove()
            option.outline:remove()
            option.outline_copy:remove()

            local member = self.battle:getNetworkMemberByKey(
                member_key or "__local"
            )
            local color = member and member.soul_color or COLORS.red
            local burst = HeartBurst(x, y, color)
            burst:setScale(3)
            burst.layer = self.layer + 1
            self.battle:addChild(burst)
            self.pick_timer = PICK_EFFECT_TIME
            if index == self.selection
                and not self.battle.event_token_selections.__local
            then
                for offset = 1, #self.options do
                    local next_index = ((index - 1 + offset) % #self.options) + 1
                    if not self.options[next_index].removed then
                        self:setSelection(next_index, true)
                        break
                    end
                end
            end
            return
        end
    end
end

function TokenSelectionEvent:isPickAnimationDone()
    return self.pick_timer == nil or self.pick_timer <= 0
end

function TokenSelectionEvent:update()
    self.timer = self.timer + DT
    self.highlight_timer = self.highlight_timer + DT
    if self.pick_timer then
        self.pick_timer = math.max(0, self.pick_timer - DT)
    end
    self.alpha = MathUtils.approach(self.alpha, self.finished and 0 or 1, FADE_SPEED * DT)
    if self.enabled
        and not self.battle.event_token_selections.__local
        and not self.battle.event_token_pending
    then
        local hovered = self:getHoveredOption()
        if hovered and hovered ~= self.selection then
            self:setSelection(hovered)
        elseif Input.pressed("left") then
            self:moveSelection(-1)
        elseif Input.pressed("right") then
            self:moveSelection(1)
        elseif Input.pressed("up") or Input.pressed("down") then
            local columns = math.ceil(#self.options / 2)
            self:moveSelection(columns)
        end

        local clicked = Input.mousePressed(1)
        if Input.pressed("confirm") or (clicked and hovered) then
            if hovered then self:setSelection(hovered) end
            self.battle:chooseEventToken(self.options[self.selection].id)
        end
    end

    local highlight_scale
    if self.highlight_timer < HIGHLIGHT_EASE_TIME then
        highlight_scale = MathUtils.lerp(
            SCALE,
            HIGHLIGHT_MIN_SCALE,
            easeOut(MathUtils.clamp(
                self.highlight_timer / HIGHLIGHT_EASE_TIME,
                0,
                1
            ))
        )
    else
        local pulse = (
            1 - math.cos(
                (self.highlight_timer - HIGHLIGHT_EASE_TIME) * 0.75
            )
        ) / 2
        highlight_scale = MathUtils.lerp(
            HIGHLIGHT_MIN_SCALE,
            HIGHLIGHT_MAX_SCALE,
            pulse
        )
    end
    local angle = self.timer * 0.75
    local offset_x = math.cos(angle) * HIGHLIGHT_ORBIT_RADIUS
    local offset_y = math.sin(angle) * HIGHLIGHT_ORBIT_RADIUS
    local can_select = self.enabled
        and not self.battle.event_token_selections.__local
        and not self.battle.event_token_pending

    for index, option in ipairs(self.options) do
        if not option.removed then
            local x, y = self:getOptionPosition(option)
            local selected = can_select and index == self.selection
            option.sprite:setPosition(x, y)
            option.sprite:setColor(COLORS.white)
            option.sprite.alpha = self.alpha
                * (can_select and not selected and 0.6 or 1)

            option.outline:setPosition(x + offset_x, y + offset_y)
            option.outline_copy:setPosition(x + offset_x, y + offset_y)
            option.outline:setScale(highlight_scale)
            option.outline_copy:setScale(highlight_scale)
            option.outline:setColor(COLORS.white)
            option.outline_copy:setColor(COLORS.white)
            option.outline.alpha = selected and self.alpha or 0
            option.outline_copy.alpha = selected and self.alpha * 0.6 or 0
        end
    end
    super.update(self)
end

function TokenSelectionEvent:drawTooltip(option, x, y)
    if not option.definition.description then return end
    local tooltip_x = MathUtils.clamp(x - TOOLTIP_WIDTH / 2, 8, SCREEN_WIDTH - TOOLTIP_WIDTH - 8)
    local tooltip_y = y + 34
    Draw.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", tooltip_x, tooltip_y, TOOLTIP_WIDTH, 64, 3, 3)
    Draw.setColor(1, 1, 1, self.alpha)
    love.graphics.rectangle("line", tooltip_x, tooltip_y, TOOLTIP_WIDTH, 64, 3, 3)
    love.graphics.setFont(Assets.getFont("main", 16))
    Draw.setColor(COLORS.yellow[1], COLORS.yellow[2], COLORS.yellow[3], self.alpha)
    love.graphics.print(option.definition.name, tooltip_x + 7, tooltip_y + 4)
    love.graphics.setFont(Assets.getFont("tenna", 8))
    Draw.setColor(1, 1, 1, self.alpha)
    love.graphics.printf(option.definition.description, tooltip_x + 7, tooltip_y + 24, TOOLTIP_WIDTH - 14, "left")
end

function TokenSelectionEvent:draw()
    local hovered = self.enabled and self:getHoveredOption()
    super.draw(self)
    for _, option in ipairs(self.options) do
        local x, y = self:getOptionPosition(option)
        if not option.removed and self.options[hovered] == option then
            self:drawTooltip(option, x, y)
        end
    end
end

return TokenSelectionEvent
