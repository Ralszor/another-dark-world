---@class Battle
local Battle, super = HookSystem.hookScript(Battle)

local SOUL_COLORS = {
    COLORS.red,
    COLORS.blue,
    COLORS.purple,
    COLORS.green,
}

local GRID_VIEW = {x = 6, y = 84, width = 224, height = 225}
local STRIP_Y = 405
local PANEL_Y = 425
local PANEL_X = 28
local PANEL_WIDTH = 135
local PANEL_HEIGHT = 52
local PANEL_GAP = 15
local CARD_Y = 105
local CARD_AMOUNT = 2
local CARD_GAP = 15
local CARD_AREA_X = 250
local CARD_AREA_WIDTH = SCREEN_WIDTH - CARD_AREA_X
local ACTION_CARD_COST = 8
local TENSION_REGEN = 4
local ACTION_BOX_WIDTH = 70
local ACTION_BOX_HEIGHT = 22
local ENEMY_FADE_SPEED = 3
local CARD_FADE_SPEED = 4
local ROUND_COMPLETE_TIME = 1.5
local CARD_SYNC_INTERVAL = 0.5
local NATIVE_PARTY_Y = 800

local function copyColor(color, fallback)
    color = color or fallback or COLORS.white
    return {color[1], color[2], color[3], color[4] or 1}
end

local function getPartyColor(party_member, actor_id)
    party_member = party_member or actor_id and Game:getPartyMember(actor_id)
    if party_member and party_member.getColor then
        return {party_member:getColor()}
    end
    return copyColor(COLORS.white)
end

local function getHealth(member)
    local source = member.battler
    if source and source.getHealth and source.getStat then
        return source:getHealth(), source:getStat("health")
    elseif member.local_player and member.chara then
        return member.chara:getHealth(), member.chara:getStat("health")
    end
end

local function getHeadTexture(member)
    if not member.chara or not member.chara.getHeadIcons then
        return nil
    end

    local path = member.chara:getHeadIcons()
    if not path then
        return nil
    end

    local success, texture = pcall(Assets.getTexture, path .. "/head")
    return success and texture or nil
end

local function getNameTexture(member)
    if not member.chara or not member.chara.getNameSprite then
        return nil
    end

    local path = member.chara:getNameSprite()
    if not path then
        return nil
    end

    local success, texture = pcall(Assets.getTexture, path)
    return success and texture or nil
end

local function printOutlined(text, x, y, color, scale)
    scale = scale or 1
    Draw.setColor(COLORS.black)
    love.graphics.print(text, x - 1, y, 0, scale, scale)
    love.graphics.print(text, x + 1, y, 0, scale, scale)
    love.graphics.print(text, x, y - 1, 0, scale, scale)
    love.graphics.print(text, x, y + 1, 0, scale, scale)
    Draw.setColor(color)
    love.graphics.print(text, x, y, 0, scale, scale)
end

local function getActorID(player, known_player)
    local actor = player and player.actor
    if type(actor) == "table" then
        return actor.id
    elseif type(actor) == "string" then
        return actor
    end
    return known_player and known_player.actor
end

local function getSelectionKey(member)
    if member.local_player then
        return "__local"
    end
    return member.uuid and tostring(member.uuid)
end

function Battle:createCardBank()
    local paths = {}
    for path in pairs(Mod.info.script_chunks or {}) do
        if path:match("^scripts/battle/cards/[^/]+$") then
            table.insert(paths, path)
        end
    end
    table.sort(paths)

    local bank = {}
    local ids = {}
    for _, path in ipairs(paths) do
        local success, card_class = pcall(modRequire, path:gsub("/", "."))
        if success and isClass(card_class) and card_class:includes(Card) then
            local card_success, card = pcall(function()
                return card_class()
            end)
            if card_success and type(card.id) == "string" and card.id ~= "" then
                assert(not bank[card.id], "Duplicate card ID: " .. card.id)
                bank[card.id] = card_class
                table.insert(ids, card.id)
            else
                Kristal.Console:warn("Skipping card without a valid ID: " .. path)
            end
        else
            Kristal.Console:warn("Skipping invalid card script: " .. path)
        end
    end
    assert(#ids > 0, "No card classes found in scripts/battle/cards")
    return bank, ids
end

function Battle:init()
    super.init(self)

    -- This is deliberately separate from Battle.party. GCSN's Other_Battler is a
    -- Character, not a PartyBattler, and the stock battle logic cannot operate on it.
    self.network_party = {}
    self.network_party_limit = #SOUL_COLORS
    self.network_grid_scroll = 0
    self.card_bank, self.card_ids = self:createCardBank()
    self.card_amount = CARD_AMOUNT
    self.card_choices = {}
    self.card_positions = {}
    self.card_selection = 1
    self.card_selections = {}
    self.card_phase = "DEALING"
    self.card_round = 1
    self.card_deal_seed = nil
    self.card_phase_total = nil
    self.card_phase_current = 0
    self.card_phase_timer = 0
    self.card_enemy_alpha = 0
    self.card_cards_alpha = 0
    self.card_sync_timer = 0
    self.card_reveal_progress = 0
    self.card_effect_resolved = false
    self.card_mouse_x = nil
    self.card_mouse_y = nil
    self.card_health_cache = {}
    self.card_tension_cache = {}
    self.tension_regen_round = nil
    self.tension = {visible = false}
    self.network_tension = {}
    self.card_cursor_was_visible = MOUSE_VISIBLE
    self.card_os_cursor_was_visible = love.mouse.isVisible()
    self:refreshNetworkParty()
end

---Creates the stock UI objects so Battle's state machine remains valid, but the
---diagram UI below is responsible for presentation.
function Battle:createUI()
    super.createUI(self)

    if self.background then
        self.background.visible = false
    end
    self:hideStockBattleUI()
end

function Battle:hideStockBattleUI()
    self.battle_ui.visible = false
    self.tension_bar.visible = false

    local detached_ui = {
        self.battle_ui.encounter_text,
        self.battle_ui.choice_box,
        self.battle_ui.short_act_text_1,
        self.battle_ui.short_act_text_2,
        self.battle_ui.short_act_text_3,
    }
    for _, object in ipairs(detached_ui) do
        object.visible = false
    end
end

function Battle:keepNativePartyOffscreen()
    for _, battler in ipairs(self.party) do
        battler.y = NATIVE_PARTY_Y
        battler.visible = false
    end
end

function Battle:postInit(state, encounter)
    super.postInit(self, state, encounter)

    self:keepNativePartyOffscreen()

    self:positionNetworkEnemies(false)
    self:setState("NONE", "CARD_GAME")

    if self.encounter.music and not self.music:isPlaying() then
        self.music:play(self.encounter.music)
    end
    self.started = true
    self.card_amount = self.encounter.card_amount or self.card_amount
    self:beginCardDecisionPhase()
    if self.card_cursor_was_visible then
        Kristal.showCursor()
    else
        love.mouse.setVisible(true)
    end
end

function Battle:onRemove(parent)
    if not self.card_cursor_was_visible then
        Kristal.hideCursor()
    end
    love.mouse.setVisible(self.card_os_cursor_was_visible)
    super.onRemove(self, parent)
end

function Battle:positionNetworkEnemies(transitioning)
    local count = #self.enemies
    local columns = math.min(count, 2)
    local rows = math.ceil(count / math.max(columns, 1))

    for index, enemy in ipairs(self.enemies) do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        local x = GRID_VIEW.x + (GRID_VIEW.width * ((column + 1) / (columns + 1)))
        local y = GRID_VIEW.y + (GRID_VIEW.height/1.3)

        enemy.target_x = x
        enemy.target_y = y
        if not transitioning then
            enemy:setPosition(x, y)
        end
    end
end

---Creates only the player-controlled party member for the stock battle.
function Battle:createPartyBattlers()
    local party_member = Game.party[1]
    if not party_member then
        return
    end

    local world_character
    if Game.world.player
        and Game.world.player.visible
        and Game.world.player.actor.id == party_member:getActor().id
    then
        world_character = Game.world.player
    else
        for _, follower in ipairs(Game.world.followers) do
            if follower.visible and follower.actor.id == party_member:getActor().id then
                world_character = follower
                break
            end
        end
    end

    local x, y = SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2
    if world_character then
        x, y = world_character:getScreenPos()
        world_character.visible = false
        self.party_world_characters[party_member.id] = world_character
    end

    local battler = PartyBattler(party_member, x, y)
    battler:setAnimation("battle/transition")
    self:addChild(battler)
    table.insert(self.party, battler)
    table.insert(self.party_beginning_positions, {x, y})
end

---Rebuilds the display party used by the multiplayer battle presentation.
---Every member, including the local player, follows GCSN's server party number.
function Battle:refreshNetworkParty()
    local party = {}
    local local_battler = self.party[1]
    local gcsn = rawget(_G, "GCSN")

    if local_battler then
        table.insert(party, {
            local_player = true,
            uuid = gcsn and gcsn.uuid,
            party_number = tonumber(local_battler.party_number) or math.huge,
            battler = local_battler,
            chara = local_battler.chara,
            actor_id = local_battler.actor and local_battler.actor.id,
            name = local_battler.chara:getName(),
            heart_sprite = "player/heart",
        })
    end

    if gcsn and gcsn.party_members then
        for uuid in pairs(gcsn.party_members) do
            local battler = gcsn.other_battlers and gcsn.other_battlers[uuid]
            local world_player = gcsn.other_players and gcsn.other_players[uuid]
            local known_player = gcsn.known_players and gcsn.known_players[uuid]
            local player = battler or world_player

            if battler then
                battler.visible = false
            end

            local actor_id = getActorID(player, known_player)
            local name = player and player.name
                or known_player and known_player.name
                or "PLAYER"

            table.insert(party, {
                local_player = false,
                uuid = uuid,
                party_number = tonumber(battler and battler.party_number) or math.huge,
                battler = battler,
                chara = actor_id and Game:getPartyMember(actor_id),
                actor_id = actor_id,
                name = name,
                heart_sprite = "player/heart",
            })
        end
    end

    table.sort(party, function(a, b)
        if a.party_number == b.party_number then
            return tostring(a.uuid or "") < tostring(b.uuid or "")
        end
        return a.party_number < b.party_number
    end)

    while #party > self.network_party_limit do
        table.remove(party)
    end

    for index, member in ipairs(party) do
        member.index = index
        member.soul_color = copyColor(SOUL_COLORS[index], COLORS.red)
        member.box_color = getPartyColor(member.chara, member.actor_id)
        if member.local_player and member.chara then
            member.chara.tension = member.chara.tension or {
                value = 0,
                max = 100,
                visible = false,
            }
            member.tension = member.chara.tension
        else
            local key = tostring(member.uuid or index)
            self.network_tension[key] = self.network_tension[key] or {
                value = 0,
                max = 100,
                visible = false,
            }
            member.tension = self.network_tension[key]
        end
    end

    self.network_party = party
end

function Battle:getNetworkParty()
    return self.network_party
end

function Battle:getCardSelectionKey(member)
    return getSelectionKey(member)
end

function Battle:getLocalNetworkMember()
    for _, member in ipairs(self.network_party) do
        if member.local_player then
            return member
        end
    end
end

function Battle:getActionCardLabel()
    local member = self:getLocalNetworkMember()
    local chara = member and member.chara
    if chara and chara.hasXAct and chara:hasXAct() then
        local name = chara.getXActName and chara:getXActName()
        if name and name ~= "" then
            return name
        end
    end
    return "ACT"
end

function Battle:getLocalTensionValue()
    local member = self:getLocalNetworkMember()
    return member and member.tension and (tonumber(member.tension.value) or 0) or 0
end

function Battle:isCardSelectable(choice)
    local card = self.card_choices[choice]
    if not card then
        return false
    end
    return not card.party_action or self:getLocalTensionValue() >= (card.tp_cost or 0)
end

function Battle:moveCardSelection(direction)
    local count = #self.card_choices
    for offset = 1, count do
        local candidate = ((self.card_selection - 1 + (offset * direction)) % count) + 1
        if self:isCardSelectable(candidate) then
            self.card_selection = candidate
            Assets.playSound("ui_move")
            return
        end
    end
end

function Battle:getCardDealLeader()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.party_members or not next(gcsn.party_members) then
        return nil
    end

    for _, member in ipairs(self.network_party) do
        if member.party_number == 1 then
            return member
        end
    end
end

function Battle:isCardPartyOnline()
    local gcsn = rawget(_G, "GCSN")
    return gcsn and gcsn.party_members and next(gcsn.party_members) ~= nil
end

function Battle:createCardDealSeed()
    local timer_part = math.floor(love.timer.getTime() * 1000000)
    local random_part = love.math.random(1, 2147483646)
    return ((timer_part + random_part) % 2147483646) + 1
end

function Battle:getCardPools()
    local enemy = self.enemies[1]
    local cards = enemy and enemy.cards
    local configured = type(cards) == "table" and next(cards) ~= nil
    local normal_source
    local action_source

    if configured then
        normal_source = cards.normal or cards[1]
        action_source = cards.xactions or cards.actions or cards[2]
    else
        normal_source = self.card_ids
        action_source = self.card_ids
    end

    local function resolvePool(source, pool_name)
        local pool = {}
        local seen = {}
        for _, id in ipairs(source or {}) do
            assert(type(id) == "string", pool_name .. " card entries must be card IDs")
            assert(self.card_bank[id], "Unknown " .. pool_name .. " card ID: " .. id)
            if not seen[id] then
                seen[id] = true
                table.insert(pool, id)
            end
        end
        return pool
    end

    local normal = resolvePool(normal_source, "normal")
    local actions = resolvePool(action_source, "X-Action")
    assert(#normal >= 2, "Card pool needs at least two unique normal card IDs")
    assert(#actions >= 1, "Card pool needs at least one X-Action card ID")
    return normal, actions
end

function Battle:sendCardDeal()
    local gcsn = rawget(_G, "GCSN")
    local leader = self:getCardDealLeader()
    if not gcsn or not gcsn.sendToServer or not leader or not leader.local_player then
        return
    end

    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_card_deal]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(self.card_round),
            tostring(self.card_deal_seed),
            tostring(self.card_phase_total),
        }, " "),
    })
end

function Battle:dealCards(amount, seed)
    local normal_ids, action_ids = self:getCardPools()
    self.card_choices = {}

    for slot = 1, 2 do
        seed = (seed * 48271) % 2147483647
        local bank_index = (seed % #normal_ids) + 1
        local id = table.remove(normal_ids, bank_index)
        local card_class = self.card_bank[id]
        local card = card_class()
        card:setSlot(slot)
        table.insert(self.card_choices, card)
    end

    local unused_action_ids = {}
    for _, id in ipairs(action_ids) do
        local already_dealt = false
        for _, card in ipairs(self.card_choices) do
            if card.id == id then
                already_dealt = true
                break
            end
        end
        if not already_dealt then
            table.insert(unused_action_ids, id)
        end
    end
    if #unused_action_ids > 0 then
        action_ids = unused_action_ids
    end

    seed = (seed * 48271) % 2147483647
    local action_id = action_ids[(seed % #action_ids) + 1]
    local action_card = self.card_bank[action_id]()
    action_card.party_action = true
    action_card.tp_cost = ACTION_CARD_COST
    action_card:setSlot(#self.card_choices + 1)
    table.insert(self.card_choices, action_card)

    local texture = Assets.getTexture("card")
    local total_width = (#self.card_choices * texture:getWidth())
        + (math.max(#self.card_choices - 1, 0) * CARD_GAP)
    local start_x = CARD_AREA_X + ((CARD_AREA_WIDTH - total_width) / 2)
    self.card_positions = {}
    for index = 1, #self.card_choices do
        self.card_positions[index] = start_x + ((index - 1) * (texture:getWidth() + CARD_GAP))
    end
end

function Battle:beginCardDecisionPhase(seed)
    local leader = self:getCardDealLeader()
    if self:isCardPartyOnline() and (not leader or not leader.local_player) and not seed then
        self.card_choices = {}
        self.card_positions = {}
        self.card_phase = "WAITING_FOR_DEAL"
        return
    end


    if self.tension_regen_round ~= self.card_round then
        local member = self:getLocalNetworkMember()
        if member and member.chara and member.chara.addTension then
            member.chara:addTension(TENSION_REGEN)
        end
        self.tension_regen_round = self.card_round
    end

    self.card_deal_seed = seed or self:createCardDealSeed()
    if not self.card_phase_total then
        self.card_phase_total = (self.card_deal_seed % 6) + 1
    end
    self.card_phase_current = self.card_round
    self:dealCards(self.card_amount, self.card_deal_seed)
    self.card_selection = 1
    self.card_selections = {}
    self.card_reveal_progress = 0
    self.card_effect_resolved = false
    self.card_phase_timer = 0
    self.card_enemy_alpha = 0
    self.card_cards_alpha = 0
    self.card_sync_timer = 0
    self.card_phase = 'ENEMY_FADE_IN'

    for _, card in ipairs(self.card_choices) do
        card:onDecisionPhase(self)
    end
    self:sendCardDeal()
end

function Battle:receiveCardDeal(data)
    if self.card_deal_seed
        or tonumber(data.round) ~= self.card_round
        or tonumber(data.seed) == nil
    then
        return
    end

    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end

    local leader = self:getCardDealLeader()
    local sent_by_host = tonumber(data.party_number) == 1
    if leader then
        sent_by_host = not leader.local_player
            and tostring(data.uuid or "") == tostring(leader.uuid or "")
    end
    if not sent_by_host then
        return
    end

    local seed = math.max(1, math.floor(tonumber(data.seed)) % 2147483647)
    self:beginCardDecisionPhase(seed)
end

function Battle:sendCardChoice(choice)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer or not choice then
        return
    end

    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_card_choice]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(self.card_round),
            tostring(choice),
        }, " "),
    })
end

function Battle:sendTensionState()
    local gcsn = rawget(_G, "GCSN")
    local player = self.party[1]
    local tension = player and player.chara and player.chara.tension
    if not gcsn or not gcsn.sendToServer or not tension then
        return
    end

    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_tension]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(tension.value or 0),
            tostring(tension.max or 100),
        }, " "),
    })
end

function Battle:receiveTensionState(data)
    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end
    local gcsn = rawget(_G, "GCSN")
    if not data.uuid or (gcsn and tostring(data.uuid) == tostring(gcsn.uuid)) then
        return
    end

    local key = tostring(data.uuid)
    local tension = self.network_tension[key] or {value = 0, max = 100, visible = false}
    tension.max = math.max(tonumber(data.max) or tension.max, 1)
    tension.value = MathUtils.clamp(tonumber(data.value) or tension.value, 0, tension.max)
    self.network_tension[key] = tension
end

function Battle:sendCardSelection(choice)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer then
        return
    end

    local player = self.party[1]
    if not player then
        return
    end

    gcsn.sendToServer({
        command = "battle",
        subCommand = "update",
        uuid = gcsn.uuid,
        actor = player.actor and player.actor.id,
        username = gcsn.name,
        sprite = player.sprite and player.sprite.sprite_options and player.sprite.sprite_options[1],
        encounter = self.encounter and self.encounter.id,
        health = {player.chara:getHealth(), player.chara:getStat("health")},
        location = {player.x, player.y},
        party_number = player.party_number,
        anotherdoor_card_round = self.card_round,
        anotherdoor_card_seed = self.card_deal_seed,
        anotherdoor_card_choice = choice,
    })

    self:sendCardChoice(choice)
end

function Battle:selectCard(choice)
    if self.card_phase ~= "CHOOSING" or self.card_selections.__local then
        return
    end

    if not self:isCardSelectable(choice) then
        Assets.stopAndPlaySound("ui_cant_select")
        return
    end

    self.card_selections.__local = choice
    Assets.playSound("ui_select")
    self:sendCardSelection(choice)
end

function Battle:receiveCardSelection(data)
    if #self.card_choices == 0
        or tonumber(data.round) ~= self.card_round
        or tonumber(data.choice) == nil
    then
        return
    end

    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end

    local gcsn = rawget(_G, "GCSN")
    local key = gcsn and data.uuid == gcsn.uuid and "__local" or tostring(data.uuid or "")
    if key ~= "" then
        self.card_selections[key] = MathUtils.clamp(math.floor(tonumber(data.choice)), 1, #self.card_choices)
    end
end

function Battle:hasEveryCardSelection()
    if #self.network_party == 0 then
        return false
    end

    for _, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        if not key or not self.card_selections[key] then
            return false
        end
    end
    return true
end

function Battle:resolveCardEffects()
    if self.card_effect_resolved then
        return
    end
    self.card_effect_resolved = true

    local local_choice = self.card_selections.__local
    local card = local_choice and self.card_choices[local_choice]
    local local_member = self:getLocalNetworkMember()

    if card and card.party_action and local_member and local_member.chara then
        local_member.chara:addTension(-(card.tp_cost or 0))
    end

    local damage = card and card:resolve(self, local_member, self.card_selections) or 0
    if damage > 0 and self.party[1] then
        self.party[1]:hurt(damage, true)
    elseif damage < 0 and self.party[1] then
        self.party[1]:heal(-damage)
    end
    self.card_phase = "RESOLVED"
    self.card_phase_timer = 0
end

function Battle:advanceCardPhase()
    if self.card_round >= self.card_phase_total then
        self.card_phase = 'ENDING'
        self.card_enemy_alpha = 0
        self.card_cards_alpha = 0
        self:setState('TRANSITIONOUT', 'CARD_GAME_COMPLETE')
        self.encounter:onBattleEnd()
        return
    end

    self.card_round = self.card_round + 1
    self.card_deal_seed = nil
    self.card_selections = {}
    self.card_choices = {}
    self.card_positions = {}
    self:beginCardDecisionPhase()
end

function Battle:getCardAtPosition(x, y)
    local card = Assets.getTexture("card")
    for index, card_x in ipairs(self.card_positions) do
        local extra_height = self.card_choices[index].party_action and ACTION_BOX_HEIGHT or 0
        if x >= card_x and x < card_x + card:getWidth()
            and y >= CARD_Y and y < CARD_Y + card:getHeight() + extra_height
        then
            return index
        end
    end
end

function Battle:updateCardGame()
    if self.card_phase == "WAITING_FOR_DEAL" then
        local leader = self:getCardDealLeader()
        if leader and leader.local_player then
            self:beginCardDecisionPhase()
        end
    elseif self.card_phase == "ENEMY_FADE_IN" then
        self.card_enemy_alpha = math.min(1, self.card_enemy_alpha + (ENEMY_FADE_SPEED * DT))
        if self.card_enemy_alpha >= 1 then
            self.card_phase = "CARD_FADE_IN"
        end
    elseif self.card_phase == "CARD_FADE_IN" then
        self.card_cards_alpha = math.min(1, self.card_cards_alpha + (CARD_FADE_SPEED * DT))
        if self.card_cards_alpha >= 1 then
            self.card_phase = "CHOOSING"
        end
    elseif self.card_phase == "CHOOSING" then
        if not self.card_selections.__local then
            local mouse_x, mouse_y = Input.getMousePosition()
            local hovered_card = self:getCardAtPosition(mouse_x, mouse_y)
            local mouse_moved = mouse_x ~= self.card_mouse_x or mouse_y ~= self.card_mouse_y
            local clicked, click_x, click_y = Input.mousePressed(1)
            local clicked_card = clicked and self:getCardAtPosition(click_x, click_y)

            if clicked_card then
                self.card_selection = clicked_card
                self:selectCard(clicked_card)
            elseif Input.pressed("left") then
                self:moveCardSelection(-1)
            elseif Input.pressed("right") then
                self:moveCardSelection(1)
            elseif Input.pressed("confirm") then
                self:selectCard(self.card_selection)
            elseif mouse_moved and hovered_card and hovered_card ~= self.card_selection then
                self.card_selection = hovered_card
                Assets.playSound("ui_move")
            end

            self.card_mouse_x = mouse_x
            self.card_mouse_y = mouse_y
        end

        if self:hasEveryCardSelection() then
            self.card_phase = "REVEAL"
            self.card_reveal_progress = 0
        end
    elseif self.card_phase == "REVEAL" then
        self.card_reveal_progress = math.min(1, self.card_reveal_progress + (5 * DT))
        if self.card_reveal_progress >= 1 then
            self:resolveCardEffects()
        end
    elseif self.card_phase == "RESOLVED" then
        self.card_phase_timer = self.card_phase_timer + DT
        if self.card_phase_timer >= ROUND_COMPLETE_TIME then
            self.card_phase = "ROUND_FADE_OUT"
        end
    elseif self.card_phase == "ROUND_FADE_OUT" then
        self.card_cards_alpha = math.max(0, self.card_cards_alpha - (CARD_FADE_SPEED * DT))
        self.card_enemy_alpha = math.max(0, self.card_enemy_alpha - (ENEMY_FADE_SPEED * DT))
        if self.card_cards_alpha <= 0 and self.card_enemy_alpha <= 0 then
            self:advanceCardPhase()
        end
    end
end

function Battle:updateCardSync()
    if not self:isCardPartyOnline() or self.card_phase == 'ENDING' then
        return
    end

    self.card_sync_timer = self.card_sync_timer + DT
    if self.card_sync_timer < CARD_SYNC_INTERVAL then
        return
    end
    self.card_sync_timer = 0

    local leader = self:getCardDealLeader()
    if self.card_deal_seed and leader and leader.local_player then
        self:sendCardDeal()
    end
    if self.card_selections.__local then
        self:sendCardChoice(self.card_selections.__local)
    end
    self:sendTensionState()
end

function Battle:spawnDoorDamageNumber(member, index, amount, healing)
    local panel_x = PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
    local head = getHeadTexture(member)
    local icon_width = head and head:getWidth() or 24
    local icon_height = head and head:getHeight() or 24
    local number = DoorDamageNumber(
        amount,
        panel_x + 5 + (icon_width / 2),
        PANEL_Y + 7 + (icon_height / 2),
        healing
    )
    self:addChild(number)
end

function Battle:updateDoorDamageNumbers()
    local active = {}
    for index, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        local health, max_health = getHealth(member)
        if key and health and max_health and max_health > 0 then
            active[key] = true
            local previous = self.card_health_cache[key]
            if previous ~= nil and health ~= previous then
                local difference = health - previous
                self:spawnDoorDamageNumber(
                    member,
                    index,
                    math.abs(difference),
                    difference > 0
                )
            end
            self.card_health_cache[key] = health
        end
    end

    for key in pairs(self.card_health_cache) do
        if not active[key] then
            self.card_health_cache[key] = nil
        end
    end
end

function Battle:spawnTensionNumber(member, index, amount)
    local panel_x = PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
    local head = getHeadTexture(member)
    local icon_width = head and head:getWidth() or 24
    local icon_height = head and head:getHeight() or 24
    local number = TensionNumber(
        amount,
        panel_x + 5 + (icon_width / 2),
        PANEL_Y + 7 + (icon_height / 2)
    )
    self:addChild(number)
end

function Battle:onPartyTensionAdded(chara, amount)
    for index, member in ipairs(self.network_party) do
        if member.local_player and member.chara == chara then
            local key = getSelectionKey(member)
            if key then
                self.card_tension_cache[key] = tonumber(member.tension.value) or 0
            end
            self:spawnTensionNumber(member, index, amount)
            return
        end
    end
end

function Battle:updateTensionNumbers()
    local active = {}
    for index, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        local tension = member.tension
        if key and tension then
            active[key] = true
            local value = tonumber(tension.value) or 0
            local previous = self.card_tension_cache[key]
            if previous ~= nil and value > previous then
                if member.local_player or self:isTensionVisible() then
                    self:spawnTensionNumber(member, index, value - previous)
                end
            end
            self.card_tension_cache[key] = value
        end
    end

    for key in pairs(self.card_tension_cache) do
        if not active[key] then
            self.card_tension_cache[key] = nil
        end
    end
end

function Battle:update()
    self:keepNativePartyOffscreen()
    self:refreshNetworkParty()
    self:updateCardGame()
    self:updateCardSync()
    self:updateDoorDamageNumbers()
    self:updateTensionNumbers()
    self.network_grid_scroll = (self.network_grid_scroll + (20 * DT)) % 24
    super.update(self)
    self:keepNativePartyOffscreen()
    self:hideStockBattleUI()
end

function Battle:drawNetworkGrid()
    local view = GRID_VIEW
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()

    love.graphics.setScissor(view.x, view.y, view.width, view.height)
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", view.x, view.y, view.width, view.height)

    Draw.setColor(0.3, 0, 0.45, 1)
    for x = view.x, view.x + view.width, 24 do
        love.graphics.line(x, view.y, x, view.y + view.height)
    end
    for y = view.y - 24 + self.network_grid_scroll, view.y + view.height, 24 do
        love.graphics.line(view.x, y, view.x + view.width, y)
    end

    if old_x then
        love.graphics.setScissor(old_x, old_y, old_w, old_h)
    else
        love.graphics.setScissor()
    end

    Draw.setColor(COLORS.white)
    love.graphics.rectangle("line", view.x, view.y, view.width, view.height)

    love.graphics.setFont(Assets.getFont("small"))
    local current = self.card_phase_current > 0 and tostring(self.card_phase_current) or "?"
    local total = self.card_phase_total and tostring(self.card_phase_total) or "?"
    love.graphics.printf(
        "PHASE " .. current .. " / " .. total,
        view.x,
        view.y + 8,
        view.width,
        "center"
    )
end

function Battle:setTensionVisible(visible)
    self.tension.visible = visible
end

function Battle:isTensionVisible()
    if self.tension.visible then
        return true
    end
    local player = self.party[1]
    local chara = player and player.chara
    if not chara then
        return false
    end
    if chara.tension and chara.tension.visible then
        return true
    end
    for _, item in ipairs(chara:getEquipment()) do
        if item.shows_tension then
            return true
        end
    end
    return false
end

function Battle:drawNetworkTension(member, x, y)
    if not member.local_player and not self:isTensionVisible() then
        return
    end

    local tension = member.tension or {value = 0, max = 100}
    local maximum = math.max(tension.max or 100, 1)
    local value = MathUtils.clamp(tension.value or 0, 0, maximum)
    local percentage = value / maximum
    local is_max = value >= maximum

    love.graphics.setFont(Assets.getFont("tenna", 8))
    Draw.setColor(is_max and PALETTE["tension_maxtext"] or PALETTE["tension_fill"])
    love.graphics.print(is_max and "TP: MAX" or ("TP: " .. math.floor(percentage * 100) .. "%"), x + 6, y - 13)

    local bar_x = x + 67
    local bar_y = y - 14
    local bar_width = PANEL_WIDTH - 74
    Draw.setColor(PALETTE["tension_back"])
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width, 9, 2, 2)
    Draw.setColor(is_max and PALETTE["tension_max"] or PALETTE["tension_fill"])
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width * percentage, 9, 2, 2)
end

function Battle:drawNetworkPartyPanel(member, x, y)
    self:drawNetworkTension(member, x, y)
    local selected = self.card_selections[getSelectionKey(member)] ~= nil
    if not selected then
        Draw.setColor(COLORS.black)
        love.graphics.rectangle("fill", x, y, PANEL_WIDTH, PANEL_HEIGHT)
        Draw.setColor(member.box_color)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x + 1, y + 1, PANEL_WIDTH - 2, PANEL_HEIGHT - 2)
        love.graphics.rectangle("line", x + 1, y + 1, PANEL_WIDTH - 2, -20)
        love.graphics.setLineWidth(1)
    end

    local head = getHeadTexture(member)
    if head then
        local scale = math.min(30 / head:getWidth(), 30 / head:getHeight())
        Draw.setColor(COLORS.white)
        Draw.draw(head, x + 5, y + 7, 0, 1, 1)
    end

    local health, max_health = getHealth(member)
    local bar_x = x + 25
    local bar_width = 70

    love.graphics.setFont(Assets.getFont("smallnumbers"))
    Draw.setColor(COLORS.white)
    love.graphics.print("HP", bar_x, y + 2)

    Draw.setColor(COLORS.dkgray)
    love.graphics.rectangle("fill", bar_x + 16, y + 16, bar_width, 8, 4, 4)
    local health_x = bar_x + 38
    local health_y = y + 8
    if health and max_health and max_health > 0 then
        Draw.setColor(member.box_color)
        love.graphics.rectangle("fill", bar_x + 16, y + 16, bar_width * MathUtils.clamp(health / max_health, 0, 1), 8, 4, 4)

        local current_text = tostring(math.floor(health))
        local max_text = "/" .. tostring(math.floor(max_health))
        printOutlined(current_text, health_x, health_y, COLORS.white)
        printOutlined(max_text, health_x + love.graphics.getFont():getWidth(current_text) + 1, health_y + 4, COLORS.white, 0.5)
    else
        local current_text = "--"
        printOutlined(current_text, health_x, health_y, COLORS.gray)
        printOutlined("/--", health_x + love.graphics.getFont():getWidth(current_text) + 1, health_y + 4, COLORS.gray, 0.5)
    end

    Draw.setColor(COLORS.white)
    local name_texture = getNameTexture(member)
    if name_texture then
        local max_width = PANEL_WIDTH - 30
        local max_height = PANEL_HEIGHT - 29
        local scale = math.min(1, max_width / name_texture:getWidth(), max_height / name_texture:getHeight())
        Draw.draw(name_texture, x + 5, y + 32, 0, scale, scale)
    else
        love.graphics.setFont(Assets.getFont("main", 16))
        local name = string.upper(tostring(member.name or "PLAYER"))
        love.graphics.print(name, x + 5, y + 32)
    end

    if self.card_phase == "CHOOSING" then
        local heart = Assets.getTexture(member.heart_sprite)
        Draw.setColor(
            member.soul_color[1],
            member.soul_color[2],
            member.soul_color[3],
            self.card_cards_alpha or 1
        )
        Draw.draw(heart, x + PANEL_WIDTH - 20, y + 10)
    end
end

function Battle:getCardHeartTarget(member, heart_width)
    local choice = self.card_selections[getSelectionKey(member)] or 1
    local rank = 0
    local count = 0
    for _, other in ipairs(self.network_party) do
        if self.card_selections[getSelectionKey(other)] == choice then
            count = count + 1
            if other == member then
                rank = count
            end
        end
    end

    local card = Assets.getTexture("card")
    local spread = 18
    local center_offset = (rank - ((count + 1) / 2)) * spread
    local x = self.card_positions[choice] + (card:getWidth() / 2) - (heart_width / 2) + center_offset
    local y = CARD_Y + card:getHeight() - 28
    return x, y
end

function Battle:drawCardHearts()
    if self.card_phase ~= "REVEAL" and self.card_phase ~= "RESOLVED" then
        return
    end

    local progress = self.card_phase == "RESOLVED" and 1 or self.card_reveal_progress
    progress = 1 - ((1 - progress) ^ 3)

    for index, member in ipairs(self.network_party) do
        local heart = Assets.getTexture(member.heart_sprite)
        local panel_x = PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
        local start_x = panel_x + PANEL_WIDTH - 20
        local start_y = PANEL_Y + 10
        local target_x, target_y = self:getCardHeartTarget(member, heart:getWidth())

        Draw.setColor(
            member.soul_color[1],
            member.soul_color[2],
            member.soul_color[3],
            self.card_cards_alpha or 1
        )
        Draw.draw(
            heart,
            MathUtils.lerp(start_x, target_x, progress),
            MathUtils.lerp(start_y, target_y, progress)
        )
    end
end

function Battle:drawCards()
    if #self.card_choices == 0 or #self.card_positions == 0 then
        return
    end

    local card = Assets.getTexture("card")
    local local_choice = self.card_selections.__local
    local alpha = self.card_cards_alpha or 1

    love.graphics.setFont(Assets.getFont("small"))
    Draw.setColor(1, 1, 1, alpha)
    local prompt = local_choice and "WAITING FOR PLAYERS..." or "CHOOSE A CARD"
    if self.card_phase == "REVEAL" then
        prompt = "CHOICES REVEALED!"
    elseif self.card_phase == "RESOLVED" then
        prompt = "ROUND COMPLETE"
    end
    local first_x = self.card_positions[1]
    local last_x = self.card_positions[#self.card_positions]
    love.graphics.printf(prompt, first_x, CARD_Y - 30, (last_x + card:getWidth()) - first_x, "center")

    for index, choice in ipairs(self.card_choices) do
        local x = self.card_positions[index]
        local selectable = self:isCardSelectable(index)
        local card_alpha = selectable and alpha or (alpha * 0.4)
        Draw.setColor(1, 1, 1, card_alpha)
        Draw.draw(card, x, CARD_Y)

        if self.card_phase == "CHOOSING" and not local_choice and self.card_selection == index then
            local highlight = selectable and (COLORS.yellow or COLORS.white)
                or COLORS.gray or COLORS.grey or COLORS.white
            Draw.setColor(highlight[1], highlight[2], highlight[3], alpha)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x - 3, CARD_Y - 3, card:getWidth() + 6, card:getHeight() + 6, 4, 4)
            love.graphics.setLineWidth(1)
        end

        Draw.setColor(1, 1, 1, card_alpha)
        love.graphics.setFont(Assets.getFont("small"))
        love.graphics.printf(choice:getName(), x + 8, CARD_Y + 14, card:getWidth() - 8, "center")

        love.graphics.setFont(Assets.getFont("main", 16))
        love.graphics.printf(choice:getEffect(), x + 3, CARD_Y + math.floor(card:getHeight() / 2), card:getWidth()-5, "center")

        if choice.party_action then
            local box_x = x + ((card:getWidth() - ACTION_BOX_WIDTH) / 2)
            local box_y = CARD_Y + card:getHeight() - 1
            Draw.setColor(COLORS.black[1], COLORS.black[2], COLORS.black[3], alpha)
            love.graphics.rectangle("fill", box_x, box_y, ACTION_BOX_WIDTH, ACTION_BOX_HEIGHT, 3, 3)
            Draw.setColor(1, 1, 1, card_alpha)
            love.graphics.rectangle("line", box_x, box_y, ACTION_BOX_WIDTH, ACTION_BOX_HEIGHT, 3, 3)

            local member = self:getLocalNetworkMember()
            local color = member and member.box_color or COLORS.white
            Draw.setColor(color[1], color[2], color[3], card_alpha)
            love.graphics.setFont(Assets.getFont("main", 16))
            love.graphics.printf(
                self:getActionCardLabel(),
                box_x,
                box_y+2,
                ACTION_BOX_WIDTH,
                "center"
            )
        end
    end

    self:drawCardHearts()
end

function Battle:drawNetworkPartyStrip()
    Draw.setColor(COLORS.purple)
    love.graphics.rectangle("fill", 0, STRIP_Y-30, SCREEN_WIDTH, 3)

    for index, member in ipairs(self.network_party) do
        local x = PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
        self:drawNetworkPartyPanel(member, x, PANEL_Y)
    end
end

function Battle:draw()
    love.graphics.push("all")
    self:drawNetworkGrid()
    love.graphics.pop()

    local visible_enemies = {}
    for _, enemy in ipairs(self.enemies) do
        if enemy.visible then
            table.insert(visible_enemies, enemy)
            enemy.visible = false
        end
    end

    local visible_damage_numbers = {}
    for _, child in ipairs(self.children) do
        if child.is_door_damage_number and child.visible then
            table.insert(visible_damage_numbers, child)
            child.visible = false
        end
    end

    super.draw(self)

    love.graphics.push("all")
    love.graphics.setScissor(GRID_VIEW.x, GRID_VIEW.y, GRID_VIEW.width, GRID_VIEW.height)
    for _, enemy in ipairs(visible_enemies) do
        local old_alpha = enemy.alpha
        enemy.visible = true
        enemy.alpha = (old_alpha or 1) * (self.card_enemy_alpha or 1)
        enemy:fullDraw()
        enemy.alpha = old_alpha
    end
    love.graphics.setScissor()
    love.graphics.pop()

    love.graphics.push("all")
    self:drawCards()
    love.graphics.pop()

    love.graphics.push("all")
    self:drawNetworkPartyStrip()
    love.graphics.pop()

    love.graphics.push("all")
    for _, number in ipairs(visible_damage_numbers) do
        number.visible = true
        number:fullDraw()
    end
    love.graphics.pop()
end

return Battle
