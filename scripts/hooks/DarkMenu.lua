---@class DarkMenu
local DarkMenu, super = HookSystem.hookScript(DarkMenu)

local PANEL_X = 28
local PANEL_Y = 425
local PANEL_WIDTH = 135
local PANEL_GAP = 15

local SOUL_COLORS = {
    COLORS.red,
    COLORS.blue,
    COLORS.purple,
    COLORS.green,
}

local PARTY_MEMBER_CACHE = {}

local function getActorID(player, known)
    local actor = player and player.actor
    if type(actor) == "table" then return actor.id end
    if type(actor) == "string" then return actor end
    local known_actor = known and known.actor
    if type(known_actor) == "table" then return known_actor.id end
    return known_actor
end

local function getPartyMember(actor_id)
    local member = actor_id and Game:getPartyMember(actor_id)
    if member then return member end
    if actor_id and PARTY_MEMBER_CACHE[actor_id] then
        return PARTY_MEMBER_CACHE[actor_id]
    end
    if actor_id and Registry.getPartyMember(actor_id) then
        local success, created = pcall(Registry.createPartyMember, actor_id)
        if success then
            PARTY_MEMBER_CACHE[actor_id] = created
            return created
        end
    end
end

local function printOutlined(text, x, y, color, scale)
    scale = scale or 1
    Draw.setColor(COLORS.black)
    love.graphics.print(text, x - 1, y, 0, scale, scale)
    love.graphics.print(text, x + 1, y, 0, scale, scale)
    love.graphics.print(text, x, y - 1, 0, scale, scale)
    love.graphics.print(text, x, y + 1, 0, scale, scale)
    Draw.setColor(color or COLORS.white)
    love.graphics.print(text, x, y, 0, scale, scale)
end

function DarkMenu:init(...)
    super.init(self, ...)
    self.anotherdoor_cashout = nil
    self.anotherdoor_cash_particles = {}
    self.anotherdoor_cash_timer = 0
    self.anotherdoor_cash_spawned = 0
    self.anotherdoor_cash_arrived = 0
    self.anotherdoor_stat_boxes = {}
end

function DarkMenu:drawAnotherDoorPanelObject(score)
    local x = PANEL_X + ((score.index - 1) * (PANEL_WIDTH + PANEL_GAP))
    local y = self:getAnotherDoorPanelY()
    local alpha = score.active and 1 or 0.5
    local key = tostring(score.uuid)
    local box = self.anotherdoor_stat_boxes[key]
    if not box then box = StatBox(score, x, y); self.anotherdoor_stat_boxes[key] = box end
    box.x, box.y = x, y
    box:setData(score)
    box:setOptions({
        alpha = alpha,
        total = score.total,
        show_tension = score.local_player or Mod:getToken() == "unveil",
    })
    box:fullDraw()
    self:drawAnotherDoorToken(score, x + PANEL_WIDTH - 20, y + 10, alpha)
    self:drawStack("ui/statuses/friend", score.bite, x + 6, y - 42, "BITE", "Next time you encounter IMAGE_FRIEND, take 100 damage per stack.")
    self:drawStack("ui/statuses/salve", score.poison, x + 30, y - 42, "POISON", "Take exact damage equal to your POISON stacks each turn.")
end

function DarkMenu:onAdd(parent)
    super.onAdd(self, parent)
    if Game.world.healthbar then
        Game.world.healthbar.visible = false
    end
end

function DarkMenu:transitionOut()
    if Game.world.healthbar then
        Game.world.healthbar.visible = true
    end
    super.transitionOut(self)
end

function DarkMenu:getAnotherDoorScores()
    local scores = {}
    local gcsn = rawget(_G, "GCSN")
    local local_member = Game.party[1]
    local local_tension = local_member and local_member.tension
        or {value = 0, max = 100}
    local local_bite = Game:getFlag("anotherdoor_bite_status", 0)
    local local_poison = Game:getFlag("anotherdoor_poison_status", 0)
    local_bite = tonumber(local_bite) or (local_bite == true and 1 or 0)
    local_poison = tonumber(local_poison) or (local_poison == true and 1 or 0)
    table.insert(scores, {
        uuid = gcsn and gcsn.uuid or "__local",
        party_number = tonumber((Mod:getLocalPartyNumber())) or 1,
        member = local_member,
        name = local_member and local_member:getName() or "PLAYER",
        total = Mod:getRoundTotal(),
        active = Mod:isRoundActive(),
        money = Mod:getLocalMoney(),
        health = local_member and local_member:getHealth() or 0,
        max_health = local_member and local_member:getStat("health") or 1,
        tension = tonumber(local_tension.value) or 0,
        tension_max = tonumber(local_tension.max) or 100,
        bite = local_bite,
        poison = local_poison,
        token = Mod:getToken(),
        local_player = true,
    })

    for uuid in pairs(gcsn and gcsn.party_members or {}) do
        local battler = gcsn.other_battlers and gcsn.other_battlers[uuid]
        local player = battler or (gcsn.other_players and gcsn.other_players[uuid])
        local known = gcsn.known_players and gcsn.known_players[uuid]
        local state = Mod.remote_round_states
            and Mod.remote_round_states[tostring(uuid)]
            or {}
        local actor_id = state.actor_id or getActorID(player, known)
        table.insert(scores, {
            uuid = tostring(uuid),
            party_number = tonumber(state.party_number)
                or tonumber(battler and battler.party_number)
                or math.huge,
            member = getPartyMember(actor_id),
            name = player and player.name or known and known.name or "PLAYER",
            total = math.max(0, math.floor(tonumber(state.total) or 0)),
            active = state.active ~= false,
            money = math.max(0, math.floor(tonumber(state.money) or 0)),
            health = tonumber(state.health),
            max_health = tonumber(state.max_health),
            tension = tonumber(state.tension) or 0,
            tension_max = tonumber(state.tension_max) or 100,
            bite = math.max(0, math.floor(tonumber(state.bite) or 0)),
            poison = math.max(0, math.floor(tonumber(state.poison) or 0)),
            token = state.token or "heart",
        })
    end

    table.sort(scores, function(a, b)
        if a.party_number == b.party_number then
            return tostring(a.uuid) < tostring(b.uuid)
        end
        return a.party_number < b.party_number
    end)
    while #scores > 4 do table.remove(scores) end
    for index, score in ipairs(scores) do score.index = index end
    return scores
end

function DarkMenu:getAnotherDoorLocalPanelX()
    for index, score in ipairs(self:getAnotherDoorScores()) do
        if score.local_player then
            return PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
        end
    end
    return PANEL_X
end

function DarkMenu:getAnotherDoorPanelY()
    -- DarkMenu itself enters from above. Applying three times the inverse menu
    -- offset starts the complete strip (including TOTAL) below the screen.
    return PANEL_Y - (3 * (self.y or 0))
end

function DarkMenu:startAnotherDoorCashout(amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    self.anotherdoor_cashout = {amount = amount, finished = amount <= 0}
    if amount <= 0 then
        Game.money = 0
        Mod:setRoundActive(false)
        Mod:startSpectatingNextActive()
        self.anotherdoor_cashout.round_ended =
            Mod:areAllRoundPlayersInactive(true)
    end
    return self.anotherdoor_cashout
end

function DarkMenu:isAnotherDoorCashingOut()
    return self.anotherdoor_cashout
        and (not self.anotherdoor_cashout.finished
            or self.anotherdoor_cashout.round_ended == true)
end

function DarkMenu:onKeyPressed(key)
    if self:isAnotherDoorCashingOut() then return end
    super.onKeyPressed(self, key)
end

function DarkMenu:updateAnotherDoorCashout()
    local cashout = self.anotherdoor_cashout
    if not cashout or cashout.finished then return end

    self.anotherdoor_cash_timer = self.anotherdoor_cash_timer + DT
    local should_spawn = math.min(
        cashout.amount,
        math.floor(self.anotherdoor_cash_timer / 0.07) + 1
    )
    while self.anotherdoor_cash_spawned < should_spawn do
        self.anotherdoor_cash_spawned = self.anotherdoor_cash_spawned + 1
        table.insert(self.anotherdoor_cash_particles, {
            age = 0,
            arrived = false,
            offset = ((self.anotherdoor_cash_spawned - 1) % 3 - 1) * 6,
        })
    end

    for _, particle in ipairs(self.anotherdoor_cash_particles) do
        particle.age = particle.age + DT
        if not particle.arrived and particle.age >= 0.52 then
            particle.arrived = true
            self.anotherdoor_cash_arrived = self.anotherdoor_cash_arrived + 1
            Mod:addLocalMoney(-1)
            Mod:addTotal(1, false)
            Assets.playSound("item")
        end
    end

    if self.anotherdoor_cash_arrived >= cashout.amount then
        cashout.finished = true
        Game.money = 0
        Mod:setRoundActive(false)
        Mod:startSpectatingNextActive()
        Mod:syncRoundState(true)
        cashout.round_ended = Mod:areAllRoundPlayersInactive(true)
    end
end

function DarkMenu:update()
    if Game.world.healthbar then
        Game.world.healthbar.visible = false
    end
    self:updateAnotherDoorCashout()
    super.update(self)
end

function DarkMenu:drawStack(texture_path, stacks, x, y, title, description)
    if stacks <= 0 then return end
    local texture = Assets.getTexture(texture_path)
    Draw.setColor(COLORS.white)
    Draw.draw(texture, x, y)
    local font = Assets.getFont("tenna", 8)
    local text = tostring(stacks)
    love.graphics.setFont(font)
    printOutlined(text, x + 20 - font:getWidth(text), y + 20 - font:getHeight(), COLORS.white)

    local screen_x, screen_y = self:localToScreenPos(x, y)
    local mouse_x, mouse_y = Input.getMousePosition()
    if mouse_x >= screen_x and mouse_x < screen_x + 20
        and mouse_y >= screen_y and mouse_y < screen_y + 20
    then
        local tooltip_x = x + 27
        if screen_x + 27 + 245 > SCREEN_WIDTH then
            tooltip_x = x - 252
        end
        Draw.setColor(COLORS.black)
        love.graphics.rectangle("fill", tooltip_x, y - 23, 245, 60, 3, 3)
        Draw.setColor(COLORS.white)
        love.graphics.rectangle("line", tooltip_x, y - 23, 245, 60, 3, 3)
        love.graphics.setFont(Assets.getFont("main", 16))
        Draw.setColor(COLORS.yellow or COLORS.white)
        love.graphics.print(title, tooltip_x + 7, y - 19)
        love.graphics.setFont(Assets.getFont("tenna", 8))
        Draw.setColor(COLORS.white)
        love.graphics.printf(description, tooltip_x + 7, y + 1, 231, "left")
    end
end

function DarkMenu:drawAnotherDoorToken(score, x, y, alpha)
    local definition = Token.DEFINITIONS[score.token]
        or Token.DEFINITIONS.heart
    local texture = Assets.getTexture("ui/token/" .. definition.texture)
    local soul = SOUL_COLORS[score.party_number] or COLORS.red
    local color = definition == Token.DEFINITIONS.heart and soul or COLORS.white
    Draw.setColor(color[1], color[2], color[3], alpha)
    Draw.draw(texture, x, y)

    if not definition.description then return end
    local screen_x, screen_y = self:localToScreenPos(x, y)
    local mouse_x, mouse_y = Input.getMousePosition()
    if mouse_x < screen_x or mouse_x >= screen_x + texture:getWidth()
        or mouse_y < screen_y or mouse_y >= screen_y + texture:getHeight()
    then
        return
    end

    local tooltip_x = x + 23
    if screen_x + 23 + 245 > SCREEN_WIDTH then
        tooltip_x = x - 252
    end
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", tooltip_x, y - 23, 245, 64, 3, 3)
    Draw.setColor(COLORS.white)
    love.graphics.rectangle("line", tooltip_x, y - 23, 245, 64, 3, 3)
    love.graphics.setFont(Assets.getFont("main", 16))
    Draw.setColor(COLORS.yellow or COLORS.white)
    love.graphics.print(definition.name, tooltip_x + 7, y - 19)
    love.graphics.setFont(Assets.getFont("tenna", 8))
    Draw.setColor(COLORS.white)
    love.graphics.printf(definition.description, tooltip_x + 7, y + 1, 231, "left")
end

function DarkMenu:drawAnotherDoorStrip()
    for _, score in ipairs(self:getAnotherDoorScores()) do
        self:drawAnotherDoorPanelObject(score)
    end
end

function DarkMenu:drawAnotherDoorCashout()
    if not self.anotherdoor_cashout then return end
    local texture = Assets.getTexture("ui/dollar")
    local panel_x = self:getAnotherDoorLocalPanelX()
    local panel_y = self:getAnotherDoorPanelY()
    local source_x = panel_x + 15
    local source_y = panel_y + 20
    local target_x = panel_x + 58
    local target_y = panel_y - 58

    for _, particle in ipairs(self.anotherdoor_cash_particles) do
        if not particle.arrived then
            local progress = MathUtils.clamp(particle.age / 0.52, 0, 1)
            local eased = 1 - ((1 - progress) ^ 3)
            local x = MathUtils.lerp(source_x + particle.offset, target_x, eased)
            local y = MathUtils.lerp(source_y, target_y, eased)
                - (math.sin(progress * math.pi) * 24)
            local scale = MathUtils.lerp(1, 0.65, eased)
            Draw.setColor(COLORS.white)
            Draw.draw(
                texture,
                x,
                y,
                0,
                scale,
                scale,
                texture:getWidth() / 2,
                texture:getHeight() / 2
            )
        end
    end
end

function DarkMenu:draw()
    super.draw(self)
    self:drawAnotherDoorStrip()
    self:drawAnotherDoorCashout()
end

return DarkMenu
