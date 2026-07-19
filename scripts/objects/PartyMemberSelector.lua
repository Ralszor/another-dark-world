---@class PartyMemberSelector : Object
local PartyMemberSelector, super = Class(Object)

local ROW_Y = 330
local NAME_Y = 195
local OPTION_SPACING = 90
local OPTION_SCALE = 2
local OUTLINE_MIN_SCALE = 2.25
local OUTLINE_MAX_SCALE = 2.5
local OUTLINE_ORBIT_RADIUS = 5
local OUTLINE_EASE_TIME = 1
local REVEAL_TIME = 0.45
local REVEAL_STAGGER = 0.1
local SLIDE_TIME = 0.3
local FLOWERY_DELAY = 1
local FLOWERY_DURATION = 5
local FLOWERY_TRAIL_INTERVAL = 0.12
local FLOWERY_FLOAT_DISTANCE = SCREEN_HEIGHT + 80
local SOUL_COLORS = {
    COLORS.red,
    COLORS.blue,
    COLORS.purple,
    COLORS.green,
}

local function easeOut(progress)
    return 1 - ((1 - progress) ^ 3)
end

local function discoverPartyMembers()
    local ids = {}
    for id in pairs(Registry.party_members or {}) do
        if id ~= "vessel" and Registry.getPartyMember(id) then
            table.insert(ids, id)
        end
    end
    table.sort(ids)
    for index, id in ipairs(ids) do
        if id == "jamm" then
            table.remove(ids, index)
            table.insert(ids, 1, id)
            break
        end
    end

    local members = {}
    for _, id in ipairs(ids) do
        local member = Game.party_data and Game.party_data[id]
            or Registry.createPartyMember(id)
        if member and member:getActor(false) then
            table.insert(members, member)
        end
    end
    return members
end

function PartyMemberSelector:init()
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self:setParallax(0, 0)
    self.layer = WORLD_LAYERS["top"] + 100

    self.shaker = 0

    self.members = discoverPartyMembers()
    self.options = {}
    self.selected = math.max(1, math.ceil(#self.members / 2))
    self.jamm_index = nil
    for index, member in ipairs(self.members) do
        if member.id == "jamm" then
            self.jamm_index = index
            break
        end
    end
    self.jamm_unlocked = self.jamm_index == nil
    self.option_spacing = math.min(
        OPTION_SPACING,
        520 / math.max(#self.members - 1, 1)
    )
    self.timer = 0
    self.highlight_timer = 0
    self.slide_timer = SLIDE_TIME
    self.confirmed = false
    self.name_sprite = nil
    self.flowery_sequence = nil
    self.fade_alpha = 1

    for index, member in ipairs(self.members) do
        local actor = member:getActor(false)
        local locked_jamm = index == self.jamm_index and not self.jamm_unlocked
        local outline = ActorSprite(actor)
        outline:setFacing("down")
        outline:setWalkSprite("walk")
        outline.walking = index == self.selected
        outline:setOrigin(0.5, 0.5)
        outline:setScale(OPTION_SCALE)
        if locked_jamm then
            outline:addFX(
                ColorMaskFX(COLORS.dkgray),
                "jamm_lock"
            )
        end
        local outline_fx = outline:addFX(OutlineFX(
            locked_jamm and COLORS.black or COLORS.white,
        {
            thickness = 1,
            cutout = true,
        }))
        self:addChild(outline)

        local outline_copy = ActorSprite(actor)
        outline_copy:setFacing("down")
        outline_copy:setWalkSprite("walk")
        outline_copy.walking = index == self.selected
        outline_copy:setOrigin(0.5, 0.5)
        outline_copy:setScale(OPTION_SCALE)
        if locked_jamm then
            outline_copy:addFX(
                ColorMaskFX(COLORS.dkgray),
                "jamm_lock"
            )
            outline_copy:addFX(
                OutlineFX(COLORS.black, {
                    thickness = 1,
                    cutout = true,
                }),
                "jamm_lock_outline"
            )
        end
        self:addChild(outline_copy)

        local sprite = ActorSprite(actor)
        sprite:setFacing("down")
        sprite:setWalkSprite("walk")
        sprite.walking = index == self.selected
        sprite:setOrigin(0.5, 1)
        sprite:setScale(OPTION_SCALE)
        if locked_jamm then
            sprite:addFX(ColorMaskFX(COLORS.dkgray), "jamm_lock")
        end
        self:addChild(sprite)

        local x = self:getTargetX(index)
        local center_y = ROW_Y - (sprite.height * sprite.scale_y / 2)
        outline:setPosition(x, center_y)
        outline_copy:setPosition(x, center_y)
        sprite:setPosition(x, ROW_Y)
        outline.alpha = 0
        outline_copy.alpha = 0
        sprite.alpha = 0
        table.insert(self.options, {
            member = member,
            sprite = sprite,
            outline = outline,
            outline_copy = outline_copy,
            outline_fx = outline_fx,
            x = x,
            start_x = x,
            target_x = x,
            alpha = 0,
            outline_alpha = 0,
        })
    end

    self:updateNameSprite()
    local selected_member = self.members[self.selected]
    if selected_member then
        Mod:syncIntroHighlight(selected_member.id, true)
    end
end

function PartyMemberSelector:getTargetX(index)
    return (SCREEN_WIDTH / 2)
        + ((index - self.selected) * self.option_spacing)
end

function PartyMemberSelector:updateNameSprite()
    if self.name_sprite then
        self.name_sprite:remove()
        self.name_sprite = nil
    end

    local member = self.members[self.selected]
    local locked_jamm = self.selected == self.jamm_index
        and not self.jamm_unlocked
    local path = locked_jamm and "name-J_Hint"
        or member and member:getNameSprite()
    if path and Assets.getTexture(path) then
        local sprite = Sprite(path, SCREEN_WIDTH / 2, NAME_Y)
        sprite:setOrigin(0.5, 0.5)
        sprite:setScale(2)
        sprite.alpha = 0
        self:addChild(sprite)
        self.name_sprite = sprite
    end
end

function PartyMemberSelector:moveSelection(direction)
    if self.confirmed or self.flowery_sequence or #self.members == 0 then
        return
    end
    local next_index = MathUtils.clamp(
        self.selected + direction,
        1,
        #self.members
    )
    if next_index == self.selected then return end

    self.selected = next_index
    self.highlight_timer = 0
    self.slide_timer = 0
    for index, option in ipairs(self.options) do
        option.start_x = option.x
        option.target_x = self:getTargetX(index)
    end
    self:updateNameSprite()
    local member = self.members[self.selected]
    if member then Mod:syncIntroHighlight(member.id, true) end
    Assets.playSound("move_selectui")
end

function PartyMemberSelector:getOptionHighlightPlayers(option)
    local players = {}
    local gcsn = rawget(_G, "GCSN")
    local local_uuid = gcsn and gcsn.uuid
        and tostring(gcsn.uuid) or "__local"
    for uuid, highlight in pairs(Mod:getIntroHighlights()) do
        local connected = tostring(uuid) == local_uuid
            or (gcsn and gcsn.party_members
                and gcsn.party_members[uuid] ~= nil)
        if connected and highlight.actor_id == option.member.id then
            local party_number = MathUtils.clamp(
                math.floor(tonumber(Mod:getOnlinePartyIndex(uuid))
                    or tonumber(highlight.party_number)
                    or 1),
                1,
                #SOUL_COLORS
            )
            table.insert(players, {
                party_number = party_number,
                color = SOUL_COLORS[party_number] or COLORS.white,
            })
        end
    end
    table.sort(players, function(a, b)
        return a.party_number < b.party_number
    end)
    return players
end

function PartyMemberSelector:getMergedHighlightColor(players)
    if #players >= 4 then return COLORS.white end
    local color = {0, 0, 0, 1}
    for _, player in ipairs(players) do
        color[1] = math.min(1, color[1] + player.color[1])
        color[2] = math.min(1, color[2] + player.color[2])
        color[3] = math.min(1, color[3] + player.color[3])
    end
    return color
end

function PartyMemberSelector:hasOtherOnlinePlayers()
    return #Mod:getOnlinePartyRoster() > 1
end

function PartyMemberSelector:setOptionAnimation(option, animation)
    for _, sprite in ipairs({
        option.sprite,
        option.outline,
        option.outline_copy,
    }) do
        sprite.walking = false
        sprite:setAnimation(animation)
    end
end

function PartyMemberSelector:resetOptionSprite(option)
    for _, sprite in ipairs({
        option.sprite,
        option.outline,
        option.outline_copy,
    }) do
        sprite:setFacing("down")
        sprite:setWalkSprite("walk")
    end
end

function PartyMemberSelector:startFlowerySequence()
    if self.flowery_sequence then return end

    local option = self.options[self.selected]
    if not option or option.member.id ~= "flowery" then return end

    self.flowery_sequence = {
        option = option,
        time = 0,
        y = ROW_Y,
        trail_timer = 0,
        hue = 0,
        floating = false,
    }
    self:setOptionAnimation(option, "battle/spare")
    Assets.playSound("jarona")
end

function PartyMemberSelector:spawnFloweryAfterimage(sequence)
    local r, g, b = ColorUtils.HSVToRGB(sequence.hue, 1, 1)
    sequence.hue = (sequence.hue + 0.12) % 1

    local afterimage = AfterImage(sequence.option.sprite, 0.75, 0.06)
    afterimage.debug_select = false
    afterimage:addFX(ColorMaskFX({r, g, b}))
    self:addChild(afterimage)
end

function PartyMemberSelector:updateFlowerySequence()
    local sequence = self.flowery_sequence
    if not sequence then return end

    sequence.time = sequence.time + DT
    if sequence.time >= FLOWERY_DELAY and not sequence.floating then
        sequence.floating = true
        Assets.playSound("here_i_come")
    end

    if sequence.floating then
        local progress = MathUtils.clamp(
            (sequence.time - FLOWERY_DELAY)
                / (FLOWERY_DURATION - FLOWERY_DELAY),
            0,
            1
        )
        sequence.y = ROW_Y - (FLOWERY_FLOAT_DISTANCE * progress)
        sequence.trail_timer = sequence.trail_timer + DT
        while sequence.trail_timer >= FLOWERY_TRAIL_INTERVAL do
            sequence.trail_timer = sequence.trail_timer
                - FLOWERY_TRAIL_INTERVAL
            self:spawnFloweryAfterimage(sequence)
        end
    end

    if sequence.time >= FLOWERY_DURATION then
        self:resetOptionSprite(sequence.option)
        self.flowery_sequence = nil
    end
end

function PartyMemberSelector:unlockJamm()
    if self.jamm_unlocked or not self.jamm_index then return end
    self.jamm_unlocked = true
    local option = self.options[self.jamm_index]
    option.sprite:removeFX("jamm_lock")
    option.outline:removeFX("jamm_lock")
    option.outline_copy:removeFX("jamm_lock")
    option.outline_copy:removeFX("jamm_lock_outline")
    option.outline_fx:setColor(
        COLORS.white[1],
        COLORS.white[2],
        COLORS.white[3],
        COLORS.white[4] or 1
    )
    self:updateNameSprite()
    Assets.playSound("select_selectui")
end

function PartyMemberSelector:isReady()
    return self.timer >= REVEAL_TIME
        + (math.max(#self.options - 1, 0) * REVEAL_STAGGER)
end

function PartyMemberSelector:isConfirmed()
    return self.confirmed
end

function PartyMemberSelector:getSelectedMember()
    return self.members[self.selected]
end

function PartyMemberSelector:fadeOut(time)
    Game.world.timer:tween(time or 0.6, self, {fade_alpha = 0}, "out-quad")
end

function PartyMemberSelector:update()
    self.timer = self.timer + DT
    self.highlight_timer = self.highlight_timer + DT
    self.shaker = MathUtils.clamp(self.shaker-0.5, 0, 999)
    Game.stage.x, Game.stage.y = love.math.random(-self.shaker, self.shaker),love.math.random(-self.shaker, self.shaker)
    self:updateFlowerySequence()
    local selected_member = self.members[self.selected]
    if selected_member then Mod:syncIntroHighlight(selected_member.id) end
    self.slide_timer = math.min(self.slide_timer + DT, SLIDE_TIME)
    local slide = easeOut(self.slide_timer / SLIDE_TIME)
    local outline_scale
    if self.highlight_timer < OUTLINE_EASE_TIME then
        local progress = easeOut(MathUtils.clamp(
            self.highlight_timer / OUTLINE_EASE_TIME,
            0,
            1
        ))
        outline_scale = MathUtils.lerp(
            OPTION_SCALE,
            OUTLINE_MIN_SCALE,
            progress
        )
    else
        local pulse_timer = self.highlight_timer - OUTLINE_EASE_TIME
        local pulse = (1 - math.cos(pulse_timer * 0.75)) / 2
        outline_scale = MathUtils.lerp(
            OUTLINE_MIN_SCALE,
            OUTLINE_MAX_SCALE,
            pulse
        )
    end
    local outline_angle = self.timer * 0.75
    local outline_offset_x = math.cos(outline_angle)
        * OUTLINE_ORBIT_RADIUS
    local outline_offset_y = math.sin(outline_angle)
        * OUTLINE_ORBIT_RADIUS

    for index, option in ipairs(self.options) do
        local reveal = easeOut(MathUtils.clamp(
            (self.timer - ((index - 1) * REVEAL_STAGGER)) / REVEAL_TIME,
            0,
            1
        ))
        option.x = MathUtils.lerp(option.start_x, option.target_x, slide)
        local selected = index == self.selected
        local highlight_players = self:getOptionHighlightPlayers(option)
        option.highlight_players = highlight_players
        local locked_jamm = index == self.jamm_index
            and not self.jamm_unlocked
        local target_alpha = selected and 1 or 0.6
        local multiplayer = self:hasOtherOnlinePlayers()
        local target_outline = (not multiplayer and selected)
            or (#highlight_players > 0)
        target_outline = target_outline and 1 or 0
        local blend = MathUtils.clamp(DT * 12, 0, 1)
        option.alpha = MathUtils.lerp(
            option.alpha,
            target_alpha * reveal,
            blend
        )
        option.outline_alpha = MathUtils.lerp(
            option.outline_alpha,
            target_outline * reveal,
            blend
        )

        local option_y = ROW_Y
        local flowery_active = self.flowery_sequence
            and self.flowery_sequence.option == option
        if flowery_active then
            option_y = self.flowery_sequence.y
        end
        option.sprite:setPosition(option.x, option_y)
        local actor_center_y = option_y
            - (option.sprite.height * option.sprite.scale_y / 2)
        option.actor_center_y = actor_center_y
        option.outline:setPosition(
            option.x + outline_offset_x,
            actor_center_y + outline_offset_y
        )
        option.outline_copy:setPosition(
            option.x + outline_offset_x,
            actor_center_y + outline_offset_y
        )
        option.sprite.alpha = option.alpha * self.fade_alpha
        option.outline.alpha = option.outline_alpha * self.fade_alpha
        option.outline_copy.alpha = option.outline_alpha
            * 0.6 * self.fade_alpha
        if target_outline > 0 then
            local merged
            if multiplayer then
                merged = self:getMergedHighlightColor(highlight_players)
            else
                merged = locked_jamm and COLORS.black or COLORS.white
            end
            option.outline_fx:setColor(
                merged[1], merged[2], merged[3], merged[4] or 1
            )
        end
        option.sprite.walking = selected and not flowery_active
        option.outline.walking = selected and not flowery_active
        option.outline_copy.walking = selected and not flowery_active
        option.outline:setScale(outline_scale)
        option.outline_copy:setScale(outline_scale)
    end

    if self.name_sprite then
        self.name_sprite.alpha = MathUtils.lerp(
            self.name_sprite.alpha,
            self:isReady() and 1 or 0,
            MathUtils.clamp(DT * 10, 0, 1)
        ) * self.fade_alpha
    end

    if self:isReady() and not self.confirmed and not self.flowery_sequence then
        local locked_jamm = self.selected == self.jamm_index
            and not self.jamm_unlocked
        if Input.keyPressed("j") and locked_jamm then
            self:unlockJamm()
        elseif Input.keyPressed("j")
            and self.members[self.selected]
            and self.members[self.selected].id == "flowery"
        then
            self:startFlowerySequence()
        elseif Input.pressed("left") then
            self:moveSelection(-1)
        elseif Input.pressed("right") then
            self:moveSelection(1)
        elseif Input.pressed("confirm") and #self.members > 0 then
            if locked_jamm then
                Assets.playSound("selectui_locked")
                self.shaker = 3
            else
                self.confirmed = true
                Assets.playSound("select_selectui")
            end
        end
    end

    super.update(self)
end

local function printOutlined(text, x, y, color, alpha)
    Draw.setColor(0, 0, 0, alpha)
    love.graphics.print(text, x - 1, y)
    love.graphics.print(text, x + 1, y)
    love.graphics.print(text, x, y - 1)
    love.graphics.print(text, x, y + 1)
    Draw.setColor(color[1], color[2], color[3], alpha)
    love.graphics.print(text, x, y)
end

function PartyMemberSelector:draw()
    super.draw(self)
    if not self:hasOtherOnlinePlayers() then return end
    love.graphics.setFont(Assets.getFont("tenna", 16))
    local font_height = love.graphics.getFont():getHeight()
    for _, option in ipairs(self.options) do
        local players = option.highlight_players or {}
        if #players >= 4 then
            printOutlined(
                "ALL",
                option.x + 22,
                (option.actor_center_y or ROW_Y) - (font_height / 2),
                COLORS.white,
                option.outline_alpha * self.alpha * self.fade_alpha
            )
        else
            local start_y = (option.actor_center_y or ROW_Y)
                - ((#players * font_height) / 2)
            for index, player in ipairs(players) do
                printOutlined(
                    "P" .. tostring(player.party_number),
                    option.x + 22,
                    start_y + ((index - 1) * font_height),
                    player.color,
                    option.outline_alpha * self.alpha * self.fade_alpha
                )
            end
        end
    end
end

return PartyMemberSelector
