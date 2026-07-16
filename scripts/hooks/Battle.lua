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
local PANEL_GAP = 15
local CARD_Y = 105
local CARD_AMOUNT = 2
local CARD_GAP = 15
local CARD_AREA_X = 250
local CARD_AREA_WIDTH = SCREEN_WIDTH - CARD_AREA_X
local ACTION_CARD_COST = 8
local TENSION_REGEN = 4
local ENEMY_FADE_SPEED = 3
local CARD_FADE_SPEED = 4
local ROUND_COMPLETE_TIME = 1.5
local CARD_PLAYER_RESOLVE_DELAY = 0.75
local RESURRECTION_DELAY = 0.75
local RESURRECTION_FILL_TIME = 1
local LAST_PLAYER_DEATH_DELAY = 0.75
local CARD_SYNC_INTERVAL = 0.5
local NATIVE_PARTY_Y = 800
local BITE_FLAG = "anotherdoor_bite_status"
local POISON_FLAG = "anotherdoor_poison_status"
local BITE_DAMAGE = 100

local function getStatusStacks(value)
    if value == true then
        return 1
    elseif type(value) == "number" then
        return math.max(0, math.floor(value))
    end
    return 0
end

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
    return StatBox.getHealth(member)
end

local function getHeadTexture(member)
    return StatBox.getHeadTexture(member)
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
    Mod:installNetworkHook()

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
    local next_battle = Mod:getNextBattle()
    self.card_battle_seed = next_battle.seed
    self.card_phase_rarities = next_battle.phases
    self.card_phase_total = #next_battle.phases
    self.card_phase_current = 0
    self.card_phase_timer = 0
    self.card_enemy_alpha = 0
    self.card_cards_alpha = 0
    self.card_sync_timer = 0
    self.card_reveal_progress = 0
    self.card_effect_resolved = false
    self.card_resolution_started = false
    self.card_resolution_delay = 0
    self.card_resolution_end = 0
    self.card_mouse_x = nil
    self.card_mouse_y = nil
    self.card_health_cache = {}
    self.card_tension_cache = {}
    self.tension_regen_round = nil
    self.poison_damage_round = nil
    self.round_death_reported = false
    self.tension = {visible = false}
    self.network_tension = {}
    self.network_statuses = {}
    self.network_money = {}
    self.door_statuses = {}
    self.network_tokens = {}
    self.network_token_types = {}
    self.network_stat_boxes = {}
    self.card_objects = {}
    self.card_resurrections = {}
    self.resurrection_serial = 0
    self.card_cursor_was_visible = MOUSE_VISIBLE
    self.card_os_cursor_was_visible = love.mouse.isVisible()
    self:refreshNetworkParty()
    self:refreshNetworkTokens()
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

    self:refreshDoorStatuses()

    self:positionNetworkEnemies(false)
    self:triggerBiteForEnemy(self.enemies[1])
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

function Battle:returnToWorld()
    local advance_phase = not self.phase_queue_advanced
    local leader = self:getCardDealLeader()
    local gcsn = rawget(_G, "GCSN")
    if leader then
        Mod.party_host_is_local = leader.local_player
        Mod.party_host_uuid = leader.local_player
            and gcsn and gcsn.uuid
            or leader.uuid
    end
    local can_advance_queue = not self:isCardPartyOnline()
        or (leader and leader.local_player)
        or (not leader and Mod:getLocalPartyNumber() == 1)
    self.phase_queue_advanced = true
    super.returnToWorld(self)
    if Mod.round_reset_pending and not Mod.round_reset_waiting_for_host then
        Mod:completeRoundReset()
    elseif not Mod:isRoundActive() then
        Mod:startSpectatingNextActive()
    end
    if advance_phase and can_advance_queue then
        Mod:advancePhaseQueue()
        if gcsn then
            Mod:syncNextBattleFlag(true, true)
        end
    end
end

function Battle:forceAnotherDoorRoundEnd()
    if self.anotherdoor_round_forced_end then return end
    self.anotherdoor_round_forced_end = true
    self.phase_queue_advanced = true
    self.card_phase = "ENDING"
    self.card_enemy_alpha = 0
    self.card_cards_alpha = 0
    self:setState("TRANSITIONOUT", "CARD_GAME_COMPLETE")
    self.encounter:onBattleEnd()
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

function Battle:replacePhaseEnemy(phase_index)
    local old_enemies = TableUtils.copy(self.enemies)
    local current_enemy = old_enemies[1]
    local fallback = current_enemy and current_enemy.id or "dummy"
    local next_enemy_id = Mod:pickEnemyForPhase(phase_index, fallback, {
        seed = self.card_battle_seed,
        phases = self.card_phase_rarities,
    })
    if not next_enemy_id then return end

    local world_character
    local world_position
    for _, enemy in ipairs(old_enemies) do
        world_character = world_character or self.enemy_world_characters[enemy]
        world_position = world_position or self.enemy_beginning_positions[enemy]
        self.enemy_world_characters[enemy] = nil
        self.enemy_beginning_positions[enemy] = nil
        enemy:remove()
    end

    self.enemies = {}
    self.enemies_index = {}
    local enemy = self.encounter:addEnemy(next_enemy_id)
    self:positionNetworkEnemies(false)
    self:triggerBiteForEnemy(enemy)
    self.enemy_beginning_positions[enemy] = world_position or {enemy.x, enemy.y}
    if world_character then
        self.enemy_world_characters[enemy] = world_character
        world_character.battler = enemy
    end
end

function Battle:getDoorStatusTarget(member_key, slot)
    local local_index = 1
    for index, member in ipairs(self.network_party) do
        if getSelectionKey(member) == member_key then
            local_index = index
            break
        end
    end

    local panel_x = PANEL_X + ((local_index - 1) * (PANEL_WIDTH + PANEL_GAP))
    return panel_x + 6 + ((slot - 1) * 24), PANEL_Y - 42
end

function Battle:refreshDoorStatuses()
    local active = {}
    for _, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        if key then
            active[key] = true
            local stacks
            if member.local_player then
                stacks = {
                    bite = getStatusStacks(Game:getFlag(BITE_FLAG, 0)),
                    poison = getStatusStacks(Game:getFlag(POISON_FLAG, 0)),
                }
            else
                stacks = self.network_statuses[key] or {bite = 0, poison = 0}
            end

            local statuses = self.door_statuses[key]
            if not statuses then
                statuses = {
                    bite = BiteStatus(self, stacks.bite, key),
                    poison = PoisonStatus(self, stacks.poison, key),
                }
                statuses.bite.is_door_status = true
                statuses.poison.is_door_status = true
                self:addChild(statuses.bite)
                self:addChild(statuses.poison)
                self.door_statuses[key] = statuses
            end
            statuses.bite:setStacks(stacks.bite)
            statuses.poison:setStacks(stacks.poison)
            if member.local_player then
                self.bite_status = statuses.bite
                self.poison_status = statuses.poison
            end
        end
    end

    for key, statuses in pairs(self.door_statuses) do
        if not active[key] then
            statuses.bite:remove()
            statuses.poison:remove()
            self.door_statuses[key] = nil
        end
    end
end

function Battle:animateBiteStatusFromCard(slot)
    if not self.bite_status then return end

    local card_texture = Assets.getTexture("card")
    local card_x = self.card_positions[slot]
    if not card_x then return end

    self.bite_status:beginAcquire(
        card_x + ((card_texture:getWidth() - self.bite_status.width) / 2),
        CARD_Y
    )
end

function Battle:animatePoisonStatusFromCard(slot)
    if not self.poison_status then return end
    local card_texture = Assets.getTexture("card")
    local card_x = self.card_positions[slot]
    if not card_x then return end
    self.poison_status:beginAcquire(
        card_x + ((card_texture:getWidth() - self.poison_status.width) / 2),
        CARD_Y
    )
end

function Battle:addBiteStatus(amount)
    local stacks = getStatusStacks(Game:getFlag(BITE_FLAG, 0))
        + math.max(1, math.floor(tonumber(amount) or 1))
    Game:setFlag(BITE_FLAG, stacks)
    if self.bite_status then
        self.bite_status:setStacks(stacks)
    end
end

function Battle:addPoisonStatus(amount, card_slot)
    if card_slot then
        self:animatePoisonStatusFromCard(card_slot)
    end
    local stacks = getStatusStacks(Game:getFlag(POISON_FLAG, 0))
        + math.max(1, math.floor(tonumber(amount) or 1))
    Game:setFlag(POISON_FLAG, stacks)
    if self.poison_status then
        self.poison_status:setStacks(stacks)
    end
end

function Battle:applyPoisonDamage()
    local stacks = getStatusStacks(Game:getFlag(POISON_FLAG, 0))
    if stacks > 0 and self.party[1] then
        self.party[1]:hurt(stacks, true)
    end
end

function Battle:triggerBiteForEnemy(enemy)
    local stacks = getStatusStacks(Game:getFlag(BITE_FLAG, 0))
    if not enemy or enemy.name ~= "IMAGE_FRIEND" or stacks <= 0 then
        return false
    end

    Game:setFlag(BITE_FLAG, 0)
    if self.bite_status then
        self.bite_status.acquiring = false
        self.bite_status:setStacks(0)
    end
    if self.party[1] then
        self.party[1]:hurt(BITE_DAMAGE * stacks, true)
    end
    return true
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
                party_number = tonumber(battler and battler.party_number)
                    or tonumber(world_player and world_player.party_number)
                    or tonumber(known_player and known_player.party_number)
                    or math.huge,
                battler = battler,
                chara = actor_id and Game:getPartyMember(actor_id),
                actor_id = actor_id,
                name = name,
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
            member.active = Mod:isRoundActive()
            member.token_id = Mod:getToken()
            member.money = Mod:getLocalMoney()
            member.chara.tension = member.chara.tension or {
                value = 0,
                max = 100,
                visible = false,
            }
            member.tension = member.chara.tension
        else
            local key = tostring(member.uuid or index)
            local round_state = Mod.remote_round_states
                and Mod.remote_round_states[key]
            member.active = not round_state or round_state.active
            member.token_id = round_state and round_state.token or "heart"
            member.money = self.network_money[key] or 0
            self.network_tension[key] = self.network_tension[key] or {
                value = 0,
                max = 100,
                visible = false,
            }
            member.tension = self.network_tension[key]
        end

        local resurrection = self.card_resurrections[getSelectionKey(member)]
        if resurrection and resurrection.started then
            member.resurrection_health = resurrection.display_health
            member.resurrection_max_health = resurrection.max_health
        end
    end

    self.network_party = party
end

function Battle:getNetworkMemberByKey(member_key)
    for index, member in ipairs(self.network_party) do
        if getSelectionKey(member) == member_key then
            return member, index
        end
    end
end

function Battle:getNetworkPanelX(index)
    return PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
end

function Battle:getNetworkPanelY()
    return PANEL_Y
end

function Battle:getNetworkPanelWidth()
    return PANEL_WIDTH
end

function Battle:setNetworkToken(member_key, token_id)
    assert(Token.DEFINITIONS[token_id], "Unknown token: " .. tostring(token_id))
    self.network_token_types[member_key] = token_id
    local token = self.network_tokens[member_key]
    if token then
        token:setToken(token_id)
    end
end

function Battle:refreshNetworkTokens()
    local active = {}
    for _, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        active[key] = true

        local token_id = member.token_id or "heart"
        self.network_token_types[key] = token_id
        local token = self.network_tokens[key]
        if not token then
            token = Token(self, key, token_id, member.soul_color)
            token.is_door_token = true
            self:addChild(token)
            self.network_tokens[key] = token
        elseif token.token_id ~= token_id then
            token:setToken(token_id)
        end
        token:setTokenColor(member.soul_color)
    end

    for key, token in pairs(self.network_tokens) do
        if not active[key] then
            token:remove()
            self.network_tokens[key] = nil
            self.network_token_types[key] = nil
        end
    end
end

function Battle:refreshNetworkStatBoxes()
    local active = {}
    for index, member in ipairs(self.network_party) do
        local key = getSelectionKey(member)
        active[key] = true
        local box = self.network_stat_boxes[key]
        if not box then
            box = StatBox(member, self:getNetworkPanelX(index), PANEL_Y)
            self:addChild(box)
            self.network_stat_boxes[key] = box
        end
        box.x, box.y = self:getNetworkPanelX(index), PANEL_Y
        box:setData(member)
        box:setOptions({selected = member.active ~= false and self.card_selections[key] ~= nil, show_tension = member.local_player or self:isTensionVisible()})
    end
    for key, box in pairs(self.network_stat_boxes) do
        if not active[key] then box:remove(); self.network_stat_boxes[key] = nil end
    end
end

function Battle:refreshCardObjects()
    for index, card in ipairs(self.card_choices) do
        local object = self.card_objects[index]
        if not object then
            object = card:createObject(self, index, self.card_positions[index], CARD_Y)
            self:addChild(object)
            self.card_objects[index] = object
        end
        object:setCard(card, index)
        object.x, object.y = self.card_positions[index], CARD_Y
    end
    for index = #self.card_objects, #self.card_choices + 1, -1 do
        self.card_objects[index]:remove()
        table.remove(self.card_objects, index)
    end
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
    Mod.party_host_uuid = gcsn.uuid
    Mod.party_host_is_local = true
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_card_deal]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(self.card_round),
            tostring(self.card_deal_seed),
            tostring(self.card_phase_total),
            tostring(self.card_battle_seed),
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
    self:refreshCardObjects()
end

function Battle:beginCardDecisionPhase(seed)
    local leader = self:getCardDealLeader()
    if self:isCardPartyOnline() and (not leader or not leader.local_player) and not seed then
        self.card_choices = {}
        self.card_positions = {}
        self:refreshCardObjects()
        self.card_phase = "WAITING_FOR_DEAL"
        return
    end

    if self.poison_damage_round ~= self.card_round then
        self.poison_damage_round = self.card_round
        self:applyPoisonDamage()
    end

    if self.tension_regen_round ~= self.card_round then
        local member = self:getLocalNetworkMember()
        if member and member.chara and member.chara.addTension then
            member.chara:addTension(TENSION_REGEN)
        end
        self.tension_regen_round = self.card_round
    end

    self.card_deal_seed = seed or Mod:getPhaseSeed(self.card_battle_seed, self.card_round)
    self.card_phase_current = self.card_round
    self:dealCards(self.card_amount, self.card_deal_seed)
    self.card_selection = 1
    self.card_selections = {}
    self.card_reveal_progress = 0
    self.card_effect_resolved = false
    self.card_resolution_started = false
    self.card_resolution_delay = 0
    self.card_resolution_end = 0
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

    Mod.party_host_uuid = data.uuid
    Mod.party_host_is_local = false

    if tonumber(data.battle_seed) then
        self.card_battle_seed = math.max(
            1,
            math.floor(tonumber(data.battle_seed)) % 2147483647
        )
        local next_battle = Mod:setNextBattleSeed(self.card_battle_seed)
        self.card_phase_rarities = next_battle.phases
        self.card_phase_total = #next_battle.phases
    elseif tonumber(data.total) then
        self.card_phase_total = math.max(1, math.floor(tonumber(data.total)))
    end

    local seed = math.max(1, math.floor(tonumber(data.seed)) % 2147483647)
    self:beginCardDecisionPhase(seed)
end

function Battle:sendCardChoice(choice)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer or not choice then return end
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
    if not gcsn or not gcsn.sendToServer or not tension then return end
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

function Battle:sendStatusState()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer then return end
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_status]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(getStatusStacks(Game:getFlag(BITE_FLAG, 0))),
            tostring(getStatusStacks(Game:getFlag(POISON_FLAG, 0))),
        }, " "),
    })
end

function Battle:sendMoneyState()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer then return end
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_money]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(Mod:getLocalMoney()),
        }, " "),
    })
end

function Battle:receiveMoneyState(data)
    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end
    local gcsn = rawget(_G, "GCSN")
    if not data.uuid or (gcsn and tostring(data.uuid) == tostring(gcsn.uuid)) then
        return
    end
    self.network_money[tostring(data.uuid)] = math.max(
        0,
        math.floor(tonumber(data.money) or 0)
    )
end

function Battle:receiveStatusState(data)
    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end
    local gcsn = rawget(_G, "GCSN")
    if not data.uuid or (gcsn and tostring(data.uuid) == tostring(gcsn.uuid)) then
        return
    end
    local key = tostring(data.uuid)
    self.network_statuses[key] = {
        bite = getStatusStacks(tonumber(data.bite)),
        poison = getStatusStacks(tonumber(data.poison)),
    }
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

    local tension = player.chara and player.chara.tension
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
        anotherdoor_battle_seed = self.card_battle_seed,
        anotherdoor_card_seed = self.card_deal_seed,
        anotherdoor_card_total = self.card_phase_total,
        anotherdoor_card_choice = choice,
        anotherdoor_tension_value = tension and tension.value,
        anotherdoor_tension_max = tension and tension.max,
        anotherdoor_money = Mod:getLocalMoney(),
    })
    self:sendCardChoice(choice)
end

function Battle:selectCard(choice)
    if self.card_phase ~= "CHOOSING" or self.card_selections.__local then
        return
    end
    local local_member = self:getLocalNetworkMember()
    if not local_member or local_member.active == false then return end

    if not self:isCardSelectable(choice) then
        Assets.stopAndPlaySound("ui_cant_select")
        return
    end

    self.card_selections.__local = choice
    Assets.playSound("ui_select")
    local card = self.card_choices[choice]
    if card and card.onSelected then
        card:onSelected(self)
    end
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
        if member.active ~= false
            and (not key or not self.card_selections[key])
        then
            return false
        end
    end
    return true
end

function Battle:resolveCardEffects()
    if self.card_resolution_started then
        return
    end
    self.card_resolution_started = true
    self.card_phase = "RESOLVING"
    self.card_phase_timer = 0

    local active_rank = 0
    local active_count = 0
    for _, member in ipairs(self.network_party) do
        if member.active ~= false then
            active_count = active_count + 1
            if member.local_player then
                active_rank = active_count
            end
        end
    end
    self.card_resolution_delay = math.max(0, active_rank - 1)
        * CARD_PLAYER_RESOLVE_DELAY
    self.card_resolution_end = math.max(0, active_count - 1)
        * CARD_PLAYER_RESOLVE_DELAY
    if active_rank == 0 then
        self.card_effect_resolved = true
    end
end

function Battle:applyLocalCardEffect()
    if self.card_effect_resolved then return end
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
    self:applyLoversMatchHeal()
end

function Battle:hasPendingResurrection()
    for _, resurrection in pairs(self.card_resurrections) do
        if not resurrection.finished then return true end
    end
    return false
end

function Battle:startRefusedResurrection(battler)
    local key = "__local"
    if self.card_resurrections[key] then return end
    battler.chara.anotherdoor_resurrecting = true
    self.card_resurrections[key] = {
        battler = battler,
        timer = 0,
        delay = RESURRECTION_DELAY,
        duration = RESURRECTION_FILL_TIME,
        max_health = battler.chara:getStat("health"),
        display_health = 0,
        local_player = true,
        started = false,
        finished = false,
    }
end

function Battle:isLocalResurrecting()
    local resurrection = self.card_resurrections.__local
    return resurrection and not resurrection.finished
end

function Battle:tryRefusedResurrection()
    local battler = self.party and self.party[1]
    if not battler
        or not battler.chara
        or battler.chara:getHealth() > 0
        or Mod:getToken() ~= "refused"
        or Mod:hasUsedRefusedResurrection()
    then
        return false
    end

    if not Mod:useRefusedResurrection() then return false end
    self:startRefusedResurrection(battler)
    battler.chara:setHealth(0)
    if not battler.is_down then battler:down() end
    return true
end

function Battle:handleLocalRoundDeath()
    if self:isLocalResurrecting() then return true end
    if self:tryRefusedResurrection() then return true end
    if self.round_death_reported then return false end

    self.round_death_reported = true
    self.round_death_timer = 0
    Game.money = 0
    Mod:syncRoundState(true)
    return false
end

function Battle:updateLocalRoundDeath()
    if not self.round_death_reported or self.round_death_finalized then return end
    self.round_death_timer = (self.round_death_timer or 0) + DT
    if self.round_death_timer >= LAST_PLAYER_DEATH_DELAY then
        self.round_death_finalized = true
        Mod:markLocalDeath()
    end
end

function Battle:spawnResurrectionNumber(member, index)
    if not member or not index then return end
    local panel_x = PANEL_X + ((index - 1) * (PANEL_WIDTH + PANEL_GAP))
    local head = getHeadTexture(member)
    local icon_width = head and head:getWidth() or 24
    local icon_height = head and head:getHeight() or 24
    self:addChild(ResurrectionNumber(
        panel_x + 5 + (icon_width / 2),
        PANEL_Y + 7 + (icon_height / 2)
    ))
end

function Battle:sendResurrectionState(max_health)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer then return end
    self.resurrection_serial = self.resurrection_serial + 1
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_resurrection]",
            tostring(self.encounter and self.encounter.id or "battle"),
            tostring(self.card_round),
            tostring(self.resurrection_serial),
            tostring(max_health),
        }, " "),
    })
end

function Battle:receiveResurrectionState(data)
    if data.encounter and self.encounter and data.encounter ~= self.encounter.id then
        return
    end
    if tonumber(data.round) ~= self.card_round or not data.uuid then return end
    local gcsn = rawget(_G, "GCSN")
    if gcsn and tostring(data.uuid) == tostring(gcsn.uuid) then return end
    local key = tostring(data.uuid)
    local serial = tonumber(data.serial) or 0
    local previous = self.card_resurrections[key]
    if previous and (previous.serial or 0) >= serial then return end

    self.card_resurrections[key] = {
        timer = 0,
        delay = 0,
        duration = RESURRECTION_FILL_TIME,
        max_health = math.max(1, tonumber(data.max_health) or 50),
        display_health = 0,
        local_player = false,
        started = true,
        finished = false,
        serial = serial,
    }
    local member, index = self:getNetworkMemberByKey(key)
    self:spawnResurrectionNumber(member, index)
    self.card_health_cache[key] = 0
    Assets.playSound("item")
end

function Battle:updateResurrections()
    for key, resurrection in pairs(self.card_resurrections) do
        resurrection.timer = resurrection.timer + DT
        if not resurrection.started
            and resurrection.timer >= resurrection.delay
        then
            resurrection.started = true
            resurrection.timer = resurrection.delay
            local member, index = self:getNetworkMemberByKey(key)
            self:spawnResurrectionNumber(member, index)
            if resurrection.local_player then
                resurrection.battler:revive()
                self:sendResurrectionState(resurrection.max_health)
            end
            Assets.playSound("item")
        end

        if resurrection.started and not resurrection.finished then
            local progress = MathUtils.clamp(
                (resurrection.timer - resurrection.delay) / resurrection.duration,
                0,
                1
            )
            local eased = progress * progress * (3 - (2 * progress))
            resurrection.display_health = MathUtils.lerp(
                0,
                resurrection.max_health,
                eased
            )
            self.card_health_cache[key] = resurrection.display_health
            if resurrection.local_player then
                resurrection.battler.chara:setHealth(resurrection.display_health)
            end
            if progress >= 1 then
                resurrection.finished = true
                resurrection.display_health = resurrection.max_health
                if resurrection.local_player then
                    resurrection.battler.chara:setHealth(resurrection.max_health)
                    resurrection.battler.chara.anotherdoor_resurrecting = nil
                    self.card_health_cache.__local = resurrection.max_health
                    self.card_resurrections[key] = nil
                    Mod:syncRoundState(true)
                end
            end
        elseif resurrection.finished and not resurrection.local_player then
            local remote = Mod.remote_round_states
                and Mod.remote_round_states[key]
            if (remote and tonumber(remote.health) >= resurrection.max_health)
                or resurrection.timer >= resurrection.duration + 2
            then
                self.card_resurrections[key] = nil
            end
        end
    end
end

function Battle:applyLoversMatchHeal()
    local local_member = self:getLocalNetworkMember()
    if not local_member or local_member.active == false then return end
    local token = local_member.token_id
    local opposite = token == "lovers_l" and "lovers_r"
        or token == "lovers_r" and "lovers_l"
    if not opposite then return end

    local local_choice = self.card_selections.__local
    if not local_choice then return end
    for _, member in ipairs(self.network_party) do
        if member ~= local_member
            and member.active ~= false
            and member.token_id == opposite
            and self.card_selections[getSelectionKey(member)] == local_choice
        then
            if self.party[1] then self.party[1]:heal(3) end
            return
        end
    end
end

function Battle:checkGameOver()
    if self:isLocalResurrecting() then
        return
    end
    -- Round death is handled by Mod:markLocalDeath so the last active player
    -- exits this encounter cleanly instead of entering Kristal's game-over.
    return
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
    self:replacePhaseEnemy(self.card_round)
    self.card_deal_seed = nil
    self.card_selections = {}
    self.card_choices = {}
    self.card_positions = {}
    self:beginCardDecisionPhase()
end

function Battle:getCardAtPosition(x, y)
    for index, object in ipairs(self.card_objects) do
        if object:containsPoint(x, y) then return index end
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
    elseif self.card_phase == "RESOLVING" then
        self.card_phase_timer = self.card_phase_timer + DT
        if not self.card_effect_resolved
            and self.card_phase_timer >= self.card_resolution_delay
        then
            self:applyLocalCardEffect()
        end
        if self.card_effect_resolved
            and self.card_phase_timer >= self.card_resolution_end
        then
            self.card_phase = "RESOLVED"
            self.card_phase_timer = 0
        end
    elseif self.card_phase == "RESOLVED" then
        self.card_phase_timer = self.card_phase_timer + DT
        if self.card_phase_timer >= ROUND_COMPLETE_TIME
            and not self:hasPendingResurrection()
        then
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
    self:sendStatusState()
    self:sendMoneyState()
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
    self:updateResurrections()
    self:refreshNetworkParty()
    self:refreshNetworkStatBoxes()
    self:refreshNetworkTokens()
    self:refreshDoorStatuses()
    self:updateCardGame()
    self:updateCardSync()
    self:updateDoorDamageNumbers()
    self:updateTensionNumbers()
    self:updateLocalRoundDeath()
    local local_member = self:getLocalNetworkMember()
    if not self.round_death_reported
        and local_member
        and local_member.chara
        and local_member.chara:getHealth() <= 0
        and not self:isLocalResurrecting()
    then
        self:handleLocalRoundDeath()
    end
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

function Battle:getCardTokenTarget(member, token_width)
    local choice = self.card_selections[getSelectionKey(member)] or 1
    local rank = 0
    local count = 0
    for _, other in ipairs(self.network_party) do
        if other.active ~= false
            and self.card_selections[getSelectionKey(other)] == choice
        then
            count = count + 1
            if other == member then
                rank = count
            end
        end
    end

    local card = Assets.getTexture("card")
    local spread = 18
    local center_offset = (rank - ((count + 1) / 2)) * spread
    local x = self.card_positions[choice] + (card:getWidth() / 2) - (token_width / 2) + center_offset
    local y = CARD_Y + card:getHeight() - 28
    return x, y
end

function Battle:drawNetworkPartyStrip()
    Draw.setColor(COLORS.purple)
    love.graphics.rectangle("fill", 0, STRIP_Y-30, SCREEN_WIDTH, 3)
end

function Battle:drawSpawnedCards(objects)
    if #objects == 0 then return end
    local first, last = objects[1], objects[#objects]
    local alpha = self.card_cards_alpha or 1
    local prompt = self.card_selections.__local and "WAITING FOR PLAYERS..." or "CHOOSE A CARD"
    if self.card_phase == "REVEAL" then
        prompt = "CHOICES REVEALED!"
    elseif self.card_phase == "RESOLVING" then
        prompt = "RESOLVING..."
    elseif self.card_phase == "RESOLVED" then
        prompt = "ROUND COMPLETE"
    end
    love.graphics.setFont(Assets.getFont("small"))
    Draw.setColor(1, 1, 1, alpha)
    love.graphics.printf(prompt, first.x, CARD_Y - 30, (last.x + last.width) - first.x, "center")
    for _, object in ipairs(objects) do
        object.visible = true
        object:fullDraw()
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
    local visible_statuses = {}
    local visible_tokens = {}
    local visible_stat_boxes = {}
    local visible_cards = {}
    for _, child in ipairs(self.children) do
        if child.is_door_damage_number and child.visible then
            table.insert(visible_damage_numbers, child)
            child.visible = false
        elseif child.is_door_stat_box and child.visible then
            table.insert(visible_stat_boxes, child)
            child.visible = false
        elseif child.is_door_card and child.visible then
            table.insert(visible_cards, child)
            child.visible = false
        elseif child.is_door_token and child.visible then
            table.insert(visible_tokens, child)
            child.visible = false
        end
    end
    for _, statuses in pairs(self.door_statuses or {}) do
        for _, status in pairs(statuses) do
            if status.visible then
                table.insert(visible_statuses, status)
                status.visible = false
            end
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
    self:drawSpawnedCards(visible_cards)
    love.graphics.pop()

    love.graphics.push("all")
    self:drawNetworkPartyStrip()
    love.graphics.pop()

    love.graphics.push("all")
    for _, box in ipairs(visible_stat_boxes) do
        box.visible = true
        box:fullDraw()
    end
    love.graphics.pop()

    love.graphics.push("all")
    for _, token in ipairs(visible_tokens) do
        token.visible = true
        token:fullDraw()
    end
    love.graphics.pop()

    love.graphics.push("all")
    for _, status in ipairs(visible_statuses) do
        status.visible = true
        status:fullDraw()
    end
    love.graphics.pop()

    love.graphics.push("all")
    for _, number in ipairs(visible_damage_numbers) do
        number.visible = true
        number:fullDraw()
    end
    love.graphics.pop()
end

return Battle
