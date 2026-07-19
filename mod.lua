local EVENT_PHASE_CHANCE = 15
local PHASE_POOL_VERSION = 3
local ENEMY_RARITY_WEIGHTS = {
    {rarity = "common", weight = 65},
    {rarity = "uncommon", weight = 15},
    {rarity = "rare", weight = 10},
    {rarity = "event_enemy", weight = 10},
}

local VALID_RARITIES = {
    common = true,
    uncommon = true,
    rare = true,
    event = true,
    event_enemy = true,
}

local NEXT_BATTLE_FLAG = "another_door_next_battle"
local MONEY_REWARD_SEED_FLAG = "another_door_money_reward_seed"
local ROUND_TOTAL_FLAG = "another_door_round_total"
local ROUND_NUMBER_FLAG = "another_door_round_number"
local ROUND_ACTIVE_FLAG = "another_door_round_active"
local TOKEN_FLAG = "another_door_token"
local REFUSED_USED_FLAG = "another_door_refused_used"
local BITE_STATUS_FLAG = "anotherdoor_bite_status"
local POISON_STATUS_FLAG = "anotherdoor_poison_status"
local MIZZLE_SECRET_FLAG = "another_door_mizzle_secret"
local DOUBLE_EFFECT_FLAG = "another_door_double_effect"
local DOUBLE_EFFECT_MUSIC = "event_double"
local DOUBLE_EFFECT_WORLD_VOLUME = 0.5
local MAX_PHASES = 6
local SEED_MODULUS = 2147483647
local SEED_MULTIPLIER = 48271

local function getRawOnlinePartyNumber(gcsn, uuid)
    if not gcsn then return nil end
    uuid = tostring(uuid or "")
    local local_uuid = tostring(gcsn.uuid or "")
    if uuid == local_uuid then
        if tonumber(gcsn.party_number) then return tonumber(gcsn.party_number) end
        local known = gcsn.known_players and gcsn.known_players[gcsn.uuid]
        if known and tonumber(known.party_number) then return tonumber(known.party_number) end
        local player = Game and Game.world and Game.world.player
        if player and tonumber(player.party_number) then return tonumber(player.party_number) end
    end
    local sources = {
        gcsn.party_members,
        gcsn.other_players,
        gcsn.other_battlers,
        gcsn.known_players,
    }
    for _, source in ipairs(sources) do
        local player = source and source[uuid]
        if tonumber(player) then
            return tonumber(player)
        elseif type(player) == "table" and tonumber(player.party_number) then
            return tonumber(player.party_number)
        end
    end
end

function Mod:getLocalPartyNumber()
    local gcsn = rawget(_G, "GCSN")
    local raw_number = gcsn and getRawOnlinePartyNumber(gcsn, gcsn.uuid)
    if raw_number then return raw_number end

    local battler = Game and Game.battle and Game.battle.party
        and Game.battle.party[1]
    if battler and tonumber(battler.party_number) then
        return tonumber(battler.party_number)
    end

    if gcsn and gcsn.uuid then
        return self:getOnlinePartyIndex(gcsn.uuid)
    end
    return nil
end

function Mod:isLocalPartyHost()
    local gcsn = rawget(_G, "GCSN")
    return gcsn
        and gcsn.party_members
        and next(gcsn.party_members) ~= nil
        and self:getLocalPartyNumber() == 1
end

function Mod:isPartyOnline()
    local gcsn = rawget(_G, "GCSN")
    return gcsn
        and gcsn.party_members
        and next(gcsn.party_members) ~= nil
end

function Mod:getLocalMoney()
    return math.max(0, math.floor(tonumber(Game.money) or 0))
end

function Mod:onKeyPressed(key)

    if key == "t" then
        Game.world.timer:script(function (wait)
        Assets.playSound("splat")
        local spr = Sprite("taunt")
        spr:setOrigin(0.5)
        spr:setScale(2)
        spr.x, spr.y = Game.world.player.x, Game.world.player.y-20
        Game.world:addChild(spr)
        spr.layer = Game.world.player.layer - 0.01
        Game.world.player:setSprite("splat")
        wait(0.5)
        spr:remove()
        Game.world.player:resetSprite()
        end)
    end
end
function Mod:addLocalMoney(amount)
    amount = tonumber(amount) or 0
    if amount > 0 and self:getToken() == "prophet" then
        amount = amount / 2
    end
    Game.money = math.max(
        0,
        (tonumber(Game.money) or 0) + amount
    )
    return self:getLocalMoney()
end

function Mod:getToken()
    local token_id = tostring(Game:getFlag(TOKEN_FLAG, "heart") or "heart")
    if Token and Token.DEFINITIONS[token_id] then return token_id end
    return "heart"
end

function Mod:setToken(token_id)
    token_id = tostring(token_id or "heart")
    assert(Token and Token.DEFINITIONS[token_id], "Unknown token: " .. token_id)
    Game:setFlag(TOKEN_FLAG, token_id)
    local member = Game.party and Game.party[1]
    if member then
        member.token_id = token_id
        member:setHealth(math.min(member:getHealth(), member:getStat("health")))
    end
    self.lover_partner_uuid = nil
    self.lover_partner_triggered = nil
    self:syncRoundState(true)
    return token_id
end

function Mod:hasUsedRefusedResurrection()
    return Game:getFlag(REFUSED_USED_FLAG, false) == true
end

function Mod:useRefusedResurrection()
    if self:hasUsedRefusedResurrection() then return false end
    Game:setFlag(REFUSED_USED_FLAG, true)
    return true
end

function Mod:markLocalDeath()
    Game.money = 0
    self:setRoundActive(false)
    local round_ended = self:areAllRoundPlayersInactive()
    if not round_ended then
        self:startSpectatingNextActive()
    end
end

function Mod:startSpectatingNextActive()
    if not self.spectating then
        self.spectator_fade_timer = 0
    end
    self.spectating = true
    local player = Game.world and Game.world.player
    if player and player.alpha > 0 then
        Game.world.timer:tween(0.35, player, {alpha = 0})
    end
    self:updateSpectating()
end

function Mod:updateSpectating()
    if not self.spectating or not Game.world then return end
    self.spectator_fade_timer = (self.spectator_fade_timer or 0) + DT
    if self.spectator_fade_timer >= 0.35 and Game.world.player then
        Game.world.player.alpha = 0
    end
    local gcsn = rawget(_G, "GCSN")
    local candidates = {}
    for uuid in pairs(gcsn and gcsn.party_members or {}) do
        local state = self.remote_round_states
            and self.remote_round_states[tostring(uuid)]
        local player = gcsn.other_players and gcsn.other_players[uuid]
        if player and player.stage and (not state or state.active) then
            local known = gcsn.known_players and gcsn.known_players[uuid]
            table.insert(candidates, {
                player = player,
                party_number = tonumber(state and state.party_number)
                    or tonumber(player.party_number)
                    or tonumber(known and known.party_number)
                    or math.huge,
                uuid = tostring(uuid),
            })
        end
    end
    table.sort(candidates, function(a, b)
        if a.party_number == b.party_number then return a.uuid < b.uuid end
        return a.party_number < b.party_number
    end)
    local local_number = tonumber((self:getLocalPartyNumber())) or 0
    local target
    for _, candidate in ipairs(candidates) do
        if candidate.party_number > local_number then
            target = candidate.player
            break
        end
    end
    target = target or (candidates[1] and candidates[1].player)
    if target and Game.world:getCameraTarget() ~= target then
        Game.world:setCameraTarget(target)
        Game.world:setCameraAttached(true)
    end
end

function Mod:checkLoverPartner()
    if not self:isRoundActive() then return end
    local token = self:getToken()
    local opposite = token == "lovers_l" and "lovers_r"
        or token == "lovers_r" and "lovers_l"
    if not opposite then
        self.lover_partner_uuid = nil
        return
    end

    local gcsn = rawget(_G, "GCSN")
    local found
    for uuid in pairs(gcsn and gcsn.party_members or {}) do
        local state = self.remote_round_states
            and self.remote_round_states[tostring(uuid)]
        if state and state.token == opposite then
            found = tostring(uuid)
            if state.active then
                self.lover_partner_uuid = found
                self.lover_partner_triggered = nil
                return
            end
        end
    end

    local partner = self.lover_partner_uuid
    if partner and not self.lover_partner_triggered then
        local state = self.remote_round_states
            and self.remote_round_states[partner]
        local still_in_party = false
        for uuid in pairs(gcsn and gcsn.party_members or {}) do
            if tostring(uuid) == partner then
                still_in_party = true
                break
            end
        end
        if not still_in_party or (state and not state.active) then
            self.lover_partner_triggered = true
            if Game.battle and Game.battle.party and Game.battle.party[1] then
                Game.battle.party[1]:hurt(100, true)
            else
                local member = Game.party and Game.party[1]
                if member then
                    member:setHealth(member:getHealth() - 100)
                    if member:getHealth() <= 0 then
                        self:markLocalDeath()
                    end
                end
            end
        end
    end
end

function Mod:getRoundTotal()
    return math.max(0, math.floor(tonumber(Game:getFlag(ROUND_TOTAL_FLAG, 0)) or 0))
end

function Mod:addTotal(amount, sync)
    amount = math.max(0, math.floor(tonumber(amount) or 1))
    local total = self:getRoundTotal() + amount
    Game:setFlag(ROUND_TOTAL_FLAG, total)
    if sync ~= false then self:syncRoundState(true) end
    return total
end

function Mod:setTotal(value, sync)
    value = math.max(0, math.floor(tonumber(value) or 0))
    Game:setFlag(ROUND_TOTAL_FLAG, value)
    if sync ~= false then self:syncRoundState(true) end
    return value
end

function Mod:getRound()
    return math.max(1, math.floor(tonumber(
        Game:getFlag(ROUND_NUMBER_FLAG, 1)
    ) or 1))
end

function Mod:isRoundActive()
    return Game:getFlag(ROUND_ACTIVE_FLAG, true) ~= false
end

function Mod:addRound(amount, sync)
    amount = math.max(0, math.floor(tonumber(amount) or 1))
    local round = self:getRound() + amount
    Game:setFlag(ROUND_NUMBER_FLAG, round)
    if sync ~= false then
        self:syncRoundState(true)
    end
    return round
end

function Mod:setRound(value, sync)
    value = math.max(1, math.floor(tonumber(value) or 1))
    Game:setFlag(ROUND_NUMBER_FLAG, value)
    if sync ~= false then
        self:syncRoundState(true)
    end
    return value
end

function Mod:broadcastRoundReset(target_round)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer or not self:isLocalPartyHost() then
        return
    end
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_round_reset] " .. tostring(
            target_round or self.round_reset_target or (self:getRound() + 1)
        ),
    })
end

function Mod:requestRoundReset(broadcast, wait_for_host, defer_completion)
    if self.round_reset_pending then
        if wait_for_host ~= true then
            self.round_reset_waiting_for_host = false
            if not Game.battle and not defer_completion then
                self:completeRoundReset()
            end
        end
        return
    end
    self.round_reset_pending = true
    self.round_reset_waiting_for_host = wait_for_host == true
    self.round_reset_target = self.round_reset_target or (self:getRound() + 1)
    self.round_over = true
    if broadcast ~= false then
        self:broadcastRoundReset()
    end
    if Game.battle and Game.battle.forceAnotherDoorRoundEnd then
        Game.battle:forceAnotherDoorRoundEnd()
    elseif not self.round_reset_waiting_for_host and not defer_completion then
        self:completeRoundReset()
    end
end

function Mod:completeRoundReset()
    if not self.round_reset_pending then return end
    self.completing_round_reset = true
    local result = self:resetRound(false)
    self.completing_round_reset = false
    return result
end

function Mod:endRound()
    self:requestRoundReset(true, false)
end

function Mod:resetRound(broadcast)
    if Game.battle and not self.completing_round_reset then
        self:requestRoundReset(broadcast)
        return 0
    end
    local next_round = self.round_reset_target or (self:getRound() + 1)
    self:setRound(next_round, false)
    Game:setFlag(ROUND_ACTIVE_FLAG, true)
    Game:setFlag(TOKEN_FLAG, "heart")
    Game:setFlag(REFUSED_USED_FLAG, false)
    Game:setFlag(BITE_STATUS_FLAG, 0)
    Game:setFlag(POISON_STATUS_FLAG, 0)
    Game.money = 0
    Game:setFlag(MONEY_REWARD_SEED_FLAG, nil)
    self.remote_round_states = {}
    self.door_ready = {}
    self.round_over = false
    self.round_reset_pending = false
    self.round_reset_waiting_for_host = false
    self.round_reset_target = nil
    self.spectating = false
    self.spectator_fade_timer = nil
    self.lover_partner_uuid = nil
    self.lover_partner_triggered = nil
    for _, member in pairs(Game.party_data or {}) do
        local stats = member:getBaseStats(false)
        stats.health = 100
        member.active = true
        member.token_id = "heart"
        member.anotherdoor_resurrecting = nil
        member:setHealth(100)
        if member.setTension then member:setTension(0) end
    end
    if Game.world then
        Game.world:setCameraTarget(nil)
        if Game.world.player then Game.world.player.alpha = 1 end
    end
    local can_advance = not self:isPartyOnline() or self:isLocalPartyHost()
    if can_advance then
        self:advancePhaseQueue()
        if rawget(_G, "GCSN") then
            self:syncNextBattleFlag(true, true)
        end
    end
    self:syncRoundState(true)
    if broadcast ~= false then self:broadcastRoundReset(next_round) end
    return 0
end

function Mod:isRoundOver()
    return self.round_over == true or self:areAllRoundPlayersInactive()
end

function Mod:setRoundActive(active)
    active = active ~= false
    Game:setFlag(ROUND_ACTIVE_FLAG, active)
    if Game.party and Game.party[1] then
        Game.party[1].active = active
    end
    self:syncRoundState(true)
end

function Mod:receiveRoundState(data)
    if not data or not data.uuid then return end
    local gcsn = rawget(_G, "GCSN")
    if gcsn and tostring(data.uuid) == tostring(gcsn.uuid) then return end
    self.remote_round_states = self.remote_round_states or {}
    local previous = self.remote_round_states[tostring(data.uuid)] or {}
    local key = tostring(data.uuid)
    self.remote_round_states[key] = {
        total = math.max(0, math.floor(tonumber(data.total) or 0)),
        active = data.active == true or tonumber(data.active) == 1,
        actor_id = data.actor_id or previous.actor_id,
        party_number = tonumber(data.party_number)
            or previous.party_number
            or math.huge,
        money = math.max(0, math.floor(tonumber(data.money) or previous.money or 0)),
        health = tonumber(data.health) or previous.health,
        max_health = tonumber(data.max_health) or previous.max_health,
        tension = tonumber(data.tension) or previous.tension or 0,
        tension_max = tonumber(data.tension_max) or previous.tension_max or 100,
        bite = math.max(0, math.floor(tonumber(data.bite) or previous.bite or 0)),
        poison = math.max(0, math.floor(tonumber(data.poison) or previous.poison or 0)),
        token = tostring(data.token or previous.token or "heart"),
    }
    local player = gcsn and gcsn.other_players
        and (gcsn.other_players[data.uuid] or gcsn.other_players[key])
    if player then
        local target_alpha = self.remote_round_states[key].active and 1 or 0
        if Game.world and Game.world.timer and player.alpha ~= target_alpha then
            Game.world.timer:tween(0.35, player, {alpha = target_alpha})
        else
            player.alpha = target_alpha
        end
    end
    if not self:isRoundActive() then
        self:areAllRoundPlayersInactive()
    end
end

function Mod:syncRoundState(force)
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer then return end
    self.round_sync_timer = (self.round_sync_timer or 0) + DT
    if not force and self.round_sync_timer < 0.5 then return end
    self.round_sync_timer = 0
    local member = Game.party and Game.party[1]
    local tension = member and member.tension or {value = 0, max = 100}
    local bite = Game:getFlag("anotherdoor_bite_status", 0)
    local poison = Game:getFlag("anotherdoor_poison_status", 0)
    bite = tonumber(bite) or (bite == true and 1 or 0)
    poison = tonumber(poison) or (poison == true and 1 or 0)
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_round]",
            tostring(self:getRoundTotal()),
            self:isRoundActive() and "1" or "0",
            tostring(self:getLocalMoney()),
            tostring(member and member:getHealth() or 0),
            tostring(member and member:getStat("health") or 1),
            tostring(tension.value or 0),
            tostring(tension.max or 100),
            tostring(bite),
            tostring(poison),
            tostring(self:getToken()),
        }, " "),
    })
end

function Mod:areAllRoundPlayersInactive(defer_completion)
    if self:isRoundActive() then return false end
    local gcsn = rawget(_G, "GCSN")
    for uuid in pairs(gcsn and gcsn.party_members or {}) do
        local state = self.remote_round_states
            and self.remote_round_states[tostring(uuid)]
        if not state or state.active then
            return false
        end
    end
    self.round_over = true
    local has_authority = not self:isPartyOnline() or self:isLocalPartyHost()
    self:requestRoundReset(
        has_authority,
        not has_authority,
        defer_completion == true
    )
    return true
end

function Mod:getUpcomingMoneyRemaining(next_battle)
    local seed = next_battle and tonumber(next_battle.seed)
    local phases = next_battle and next_battle.phases
    if not seed or type(phases) ~= "table" then
        return 0
    end

    seed = math.max(1, math.floor(seed) % SEED_MODULUS)
    local progress = Game:getFlag(MONEY_REWARD_SEED_FLAG)
    if tonumber(progress) == seed then
        return 0
    end
    if type(progress) == "table" and tonumber(progress.seed) == seed then
        return math.max(0, #phases - math.floor(tonumber(progress.paid) or 0))
    end
    return #phases
end

function Mod:claimUpcomingMoney(next_battle)
    local remaining = self:getUpcomingMoneyRemaining(next_battle)
    if remaining <= 0 then return false end

    local total = #next_battle.phases
    local paid = total - remaining + 1
    self:addLocalMoney(1)
    Game:setFlag(MONEY_REWARD_SEED_FLAG, {
        seed = next_battle.seed,
        paid = paid,
    })
    return true
end

function Mod:markDoorReady(seed, uuid)
    seed = tostring(math.floor(tonumber(seed) or 0))
    self.door_ready = self.door_ready or {}
    self.door_ready[seed] = self.door_ready[seed] or {}
    self.door_ready[seed][tostring(uuid or "__local")] = true
end

function Mod:syncDoorReady(seed, force)
    local gcsn = rawget(_G, "GCSN")
    local uuid = gcsn and gcsn.uuid or "__local"
    self:markDoorReady(seed, uuid)
    if not gcsn or not gcsn.sendToServer then return end

    self.door_ready_sync_timer = (self.door_ready_sync_timer or 0) + DT
    if not force and self.door_ready_sync_timer < 0.25 then return end
    self.door_ready_sync_timer = 0
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_door_ready] " .. tostring(seed),
    })
end

function Mod:areDoorPlayersReady(seed)
    local gcsn = rawget(_G, "GCSN")
    if not self:isPartyOnline() then return true end

    local ready = self.door_ready
        and self.door_ready[tostring(math.floor(tonumber(seed) or 0))]
        or {}
    if not ready[tostring(gcsn.uuid or "__local")] then
        return false
    end
    for uuid in pairs(gcsn.party_members or {}) do
        local round_state = self.remote_round_states
            and self.remote_round_states[tostring(uuid)]
        if (not round_state or round_state.active)
            and not ready[tostring(uuid)]
        then
            return false
        end
    end
    return true
end

function Mod:markIntroReady(uuid, actor_id)
    self.intro_ready = self.intro_ready or {}
    self.intro_ready[tostring(uuid or "__local")] = tostring(actor_id or "")
end

function Mod:syncIntroReady(actor_id, force)
    local gcsn = rawget(_G, "GCSN")
    local uuid = gcsn and gcsn.uuid or "__local"
    self:markIntroReady(uuid, actor_id)
    if not gcsn or not gcsn.sendToServer then return end
    self.intro_ready_sync_timer = (self.intro_ready_sync_timer or 0) + DT
    if not force and self.intro_ready_sync_timer < 0.25 then return end
    self.intro_ready_sync_timer = 0
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_intro_ready] " .. tostring(actor_id),
    })
end

function Mod:areIntroPlayersReady()
    local gcsn = rawget(_G, "GCSN")
    local local_key = gcsn and gcsn.uuid
        and tostring(gcsn.uuid) or "__local"
    if not self.intro_ready or not self.intro_ready[local_key] then return false end
    local roster = self:getOnlinePartyRoster()
    if #roster <= 1 then return true end
    for _, player in ipairs(roster) do
        if player.uuid ~= local_key and not self.intro_ready[player.uuid] then
            return false
        end
    end
    return true
end

function Mod:getOnlinePartyRoster()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn then return {{uuid = "__local", index = 1}} end
    local uuids = {[tostring(gcsn.uuid or "__local")] = true}
    for uuid in pairs(gcsn.party_members or {}) do
        local remote = gcsn.other_players and gcsn.other_players[uuid]
        if remote and remote.parent then
            uuids[tostring(uuid)] = true
        end
    end
    local roster = {}
    for uuid in pairs(uuids) do
        local state = self.remote_round_states and self.remote_round_states[uuid]
        table.insert(roster, {
            uuid = uuid,
            party_number = getRawOnlinePartyNumber(gcsn, uuid)
                or tonumber(state and state.party_number),
        })
    end
    table.sort(roster, function(a, b)
        local a_number = a.party_number or math.huge
        local b_number = b.party_number or math.huge
        if a_number == b_number then return a.uuid < b.uuid end
        return a_number < b_number
    end)
    for index, player in ipairs(roster) do player.index = index end
    return roster
end

function Mod:getOnlinePartyIndex(uuid)
    uuid = tostring(uuid or "__local")
    for _, player in ipairs(self:getOnlinePartyRoster()) do
        if player.uuid == uuid then return player.index end
    end
    return 1
end

function Mod:getPartyNumberForUUID(uuid)
    return self:getOnlinePartyIndex(uuid)
end

function Mod:markIntroHighlight(uuid, actor_id, party_number)
    self.intro_highlights = self.intro_highlights or {}
    uuid = tostring(uuid or "__local")
    self.intro_highlights[uuid] = {
        actor_id = tostring(actor_id or ""),
        party_number = self:getOnlinePartyIndex(uuid)
            or tonumber(party_number)
            or 1,
    }
end

function Mod:syncIntroHighlight(actor_id, force)
    local gcsn = rawget(_G, "GCSN")
    local uuid = gcsn and gcsn.uuid or "__local"
    local party_number = self:getOnlinePartyIndex(uuid)
    self:markIntroHighlight(uuid, actor_id, party_number)
    if not gcsn or not gcsn.sendToServer then return end
    self.intro_highlight_sync_timer = (self.intro_highlight_sync_timer or 0) + DT
    if not force and self.intro_highlight_sync_timer < 0.15 then return end
    self.intro_highlight_sync_timer = 0
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = table.concat({
            "[anotherdoor_intro_highlight]",
            tostring(actor_id),
            tostring(party_number),
        }, " "),
    })
end

function Mod:getIntroHighlights()
    return self.intro_highlights or {}
end

function Mod:isPartyHostPacket(player, uuid)
    uuid = tostring(uuid or player and player.uuid or "")
    if self.party_host_uuid
        and uuid ~= ""
        and uuid == tostring(self.party_host_uuid)
    then
        return true
    end

    if tonumber(player and player.party_number) == 1 then
        return true
    end

    local gcsn = rawget(_G, "GCSN")
    if not gcsn or uuid == "" then return false end

    local sources = {
        gcsn.other_players,
        gcsn.other_battlers,
        gcsn.known_players,
    }
    for _, source in ipairs(sources) do
        local known = source and source[uuid]
        if known and tonumber(known.party_number) == 1 then
            return true
        end
    end

    -- Party-number metadata can arrive a packet later than chat. If no host is
    -- known yet, accept the control packet from a current party member; only
    -- the local host is allowed to send this packet below.
    for _, source in ipairs(sources) do
        for _, known in pairs(source or {}) do
            if tonumber(known.party_number) == 1 then
                return false
            end
        end
    end
    return gcsn.party_members[uuid] ~= nil
end

function Mod:syncNextBattleFlag(force, leader_override)
    self.next_battle_sync_timer = (self.next_battle_sync_timer or 0) + DT
    if not force and self.next_battle_sync_timer < 0.5 then return end
    self.next_battle_sync_timer = 0

    local gcsn = rawget(_G, "GCSN")
    local is_host = leader_override
        or self.party_host_is_local
        or self:isLocalPartyHost()
    if not gcsn or not gcsn.sendToServer or not is_host then
        return
    end

    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_next_battle] "
            .. tostring(self:getNextBattle().seed)
            .. " "
            .. (self:isMizzleSecretActive() and "1" or "0")
            .. " "
            .. tostring(self:getDoubleEffectBattles()),
    })
end

function Mod:isMizzleSecretActive()
    return Game:getFlag(MIZZLE_SECRET_FLAG, false) == true
end

function Mod:setMizzleSecret(active, sync)
    active = active == true
    Game:setFlag(MIZZLE_SECRET_FLAG, active)
    if sync ~= false then
        self:syncNextBattleFlag(true)
    end
    return active
end

function Mod:getDoubleEffectBattles()
    local remaining = Game:getFlag(DOUBLE_EFFECT_FLAG, 0)
    -- Migrate saves made while this flag was a boolean.
    if remaining == true then return 1 end
    return math.max(0, math.floor(tonumber(remaining) or 0))
end

function Mod:isDoubleEffectActive()
    return self:getDoubleEffectBattles() > 0
end

function Mod:setDoubleEffectBattles(remaining, sync)
    remaining = math.max(0, math.floor(tonumber(remaining) or 0))
    Game:setFlag(DOUBLE_EFFECT_FLAG, remaining)
    if sync ~= false then self:syncNextBattleFlag(true) end
    return remaining
end

function Mod:setDoubleEffectActive(active, sync)
    return self:setDoubleEffectBattles(active == true and 1 or 0, sync)
end

function Mod:pickPostBattleEvent(seed)
    seed = math.max(1, math.floor(tonumber(seed) or 1))
    local roll = ((seed * SEED_MULTIPLIER) % SEED_MODULUS) % 100
    if roll < 10 then return "double_effect" end
end

function Mod:preparePostBattleEvent(seed, completed_double_effect, allow_roll)
    if completed_double_effect then
        self:setDoubleEffectBattles(
            self:getDoubleEffectBattles() - 1,
            false
        )
    end
    self.pending_post_battle_event = nil
    if allow_roll == false then return end
    -- Do not reroll or reannounce the event while its current run is active.
    if self:isDoubleEffectActive() then return end

    local event_id = self:pickPostBattleEvent(seed)
    if event_id == "double_effect" then
        seed = math.max(1, math.floor(tonumber(seed) or 1))
        local duration_roll = (seed * SEED_MULTIPLIER) % SEED_MODULUS
        local duration = 2 + (math.floor(duration_roll / 100) % 4)
        self:setDoubleEffectBattles(duration, false)
        self.pending_post_battle_event = {
            id = event_id,
            seed = seed,
            duration = duration,
        }
    end
end

function Mod:runPendingPostBattleEvent(cutscene)
    local event = self.pending_post_battle_event
    if not event then return false end
    self.pending_post_battle_event = nil
    local transition = self.post_battle_snapshot_transition
    if transition and not transition:isDone() then
        cutscene:wait(function() return transition:isDone() end)
    end
    self.post_battle_snapshot_transition = nil
    local callback = Registry.getWorldCutscene("post_battle", event.id)
    if callback then
        callback(cutscene, event.seed, event.duration)
        return true
    end
    return false
end

function Mod:startPendingPostBattleEvent()
    local event = self.pending_post_battle_event
    local transition = self.post_battle_snapshot_transition
    if not event
        or not Game.world
        or Game.world:hasCutscene()
        or Game.battle
        or (transition and not transition:isDone())
    then
        return false
    end
    self.post_battle_snapshot_transition = nil
    self.pending_post_battle_event = nil
    Game.world:startCutscene(
        "post_battle",
        event.id,
        event.seed,
        event.duration
    )
    return true
end

function Mod:updateDoubleEffectWorldMusic()
    local world = Game.world
    if not world or not world.music or Game.battle then return end

    local music = world.music
    if self:isDoubleEffectActive() then
        local transition = self.post_battle_snapshot_transition
        if not self.double_effect_world_music_active
            and transition
            and not transition:isDone()
        then
            return
        end
        if music.current ~= DOUBLE_EFFECT_MUSIC then
            music:play(DOUBLE_EFFECT_MUSIC, 0)
            music:fade(DOUBLE_EFFECT_WORLD_VOLUME, 0.5)
        end
        self.double_effect_world_music_active = true
        return
    end

    if not self.double_effect_world_music_active then return end
    self.double_effect_world_music_active = false

    local map_music = world.map and world.map.music
    local music_id, volume, pitch = map_music, 1, 1
    if type(map_music) == "table" then
        music_id = map_music[1]
        volume = map_music[2] or volume
        pitch = map_music[3] or pitch
    end
    if music_id and music_id ~= "" then
        music:play(music_id, 0, pitch)
        music:fade(volume, 0.5)
    else
        music:fade(0, 0.5, function(current) current:stop() end)
    end
end

function Mod:movePlayerToSpawn()
    local world = Game.world
    if not world or not world.player or not world.map then return end
    local x, y, marker = world.map:getMarker("spawn")
    if marker then world.player:setPosition(x, y) end
end

function Mod:markWorldTextReady(sync_id, uuid)
    sync_id = tostring(sync_id or "")
    if sync_id == "" then return end
    self.world_text_ready = self.world_text_ready or {}
    self.world_text_ready[sync_id] = self.world_text_ready[sync_id] or {}
    self.world_text_ready[sync_id][tostring(uuid or "__local")] = true
end

function Mod:syncWorldTextReady(sync_id, force)
    local gcsn = rawget(_G, "GCSN")
    local uuid = gcsn and gcsn.uuid or "__local"
    self:markWorldTextReady(sync_id, uuid)
    if not gcsn or not gcsn.sendToServer then return end
    self.world_text_sync_timers = self.world_text_sync_timers or {}
    local timer = (self.world_text_sync_timers[sync_id] or 0) + DT
    self.world_text_sync_timers[sync_id] = timer
    if not force and timer < 0.25 then return end
    self.world_text_sync_timers[sync_id] = 0
    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_world_text_ready] " .. tostring(sync_id),
    })
end

function Mod:areWorldTextPlayersReady(sync_id)
    local ready = self.world_text_ready and self.world_text_ready[sync_id] or {}
    local gcsn = rawget(_G, "GCSN")
    local local_uuid = gcsn and gcsn.uuid
        and tostring(gcsn.uuid)
        or "__local"
    if not ready[local_uuid] then return false end
    if not self:isPartyOnline() then return true end
    for _, player in ipairs(self:getOnlinePartyRoster()) do
        local state = self.remote_round_states
            and self.remote_round_states[player.uuid]
        if (not state or state.active)
            and not ready[player.uuid]
        then
            return false
        end
    end
    return true
end

function Mod:clearWorldTextReady(sync_id)
    if self.world_text_ready then self.world_text_ready[sync_id] = nil end
    if self.world_text_sync_timers then
        self.world_text_sync_timers[sync_id] = nil
    end
end

function Mod:normalizeRarity(rarity)
    rarity = tostring(rarity or "common"):lower()
    if rarity == "events" then rarity = "event" end
    return VALID_RARITIES[rarity] and rarity or "common"
end

function Mod:rollPhaseRarity()
    return self:getRarityForRoll(
        love.math.random(1, 100),
        love.math.random(1, 100)
    )
end

function Mod:getRarityForRoll(phase_roll, enemy_roll)
    if phase_roll <= EVENT_PHASE_CHANCE then
        return "event"
    end

    enemy_roll = enemy_roll or phase_roll
    local total = 0
    for _, entry in ipairs(ENEMY_RARITY_WEIGHTS) do
        local weight = entry.weight
        if self:isMizzleSecretActive() then
            if entry.rarity == "common" then
                weight = weight - 2
            elseif entry.rarity == "event_enemy" then
                weight = weight + 2
            end
        end
        total = total + weight
        if enemy_roll <= total then return entry.rarity end
    end
    return "common"
end

function Mod:createBattleFromSeed(seed)
    seed = math.max(1, math.floor(tonumber(seed) or 1) % SEED_MODULUS)
    local phase_count = (seed % MAX_PHASES) + 1
    local phases = {}
    local phase_seed = seed
    for index = 1, phase_count do
        phase_seed = (phase_seed * SEED_MULTIPLIER) % SEED_MODULUS
        phases[index] = self:getRarityForRoll(
            (phase_seed % 100) + 1,
            (math.floor(phase_seed / 100) % 100) + 1
        )
    end

    local next_battle = {
        seed = seed,
        phases = phases,
        pool_version = PHASE_POOL_VERSION,
    }
    Game:setFlag(NEXT_BATTLE_FLAG, next_battle)
    return next_battle
end

function Mod:generateNextBattle()
    return self:createBattleFromSeed(
        love.math.random(1, SEED_MODULUS - 1)
    )
end

function Mod:setNextBattleSeed(seed)
    seed = math.max(1, math.floor(tonumber(seed) or 1) % SEED_MODULUS)
    local current = Game:getFlag(NEXT_BATTLE_FLAG)
    if type(current) == "table"
        and current.seed == seed
        and current.pool_version == PHASE_POOL_VERSION
    then
        return current
    end
    return self:createBattleFromSeed(seed)
end

function Mod:getNextBattle()
    local next_battle = Game:getFlag(NEXT_BATTLE_FLAG)
    if type(next_battle) == "table"
        and type(next_battle.seed) == "number"
        and type(next_battle.phases) == "table"
        and next_battle.pool_version == PHASE_POOL_VERSION
        and #next_battle.phases == ((next_battle.seed % MAX_PHASES) + 1)
    then
        for _, rarity in ipairs(next_battle.phases) do
            if not VALID_RARITIES[rarity] then
                return self:createBattleFromSeed(next_battle.seed)
            end
        end
        return next_battle
    end
    if type(next_battle) == "table"
        and type(next_battle.seed) == "number"
    then
        return self:createBattleFromSeed(next_battle.seed)
    end
    return self:generateNextBattle()
end

function Mod:getPhaseQueue()
    return self:getNextBattle().phases
end

function Mod:advancePhaseQueue()
    return self:generateNextBattle().phases
end

function Mod:getPhaseSeed(battle_seed, round)
    local seed = math.max(1, math.floor(tonumber(battle_seed) or 1) % SEED_MODULUS)
    for _ = 1, math.max(1, tonumber(round) or 1) do
        seed = (seed * SEED_MULTIPLIER) % SEED_MODULUS
    end
    return seed
end

function Mod:getEnemyPools()
    if self.enemy_pools then return self.enemy_pools end

    local pools = {
        common = {},
        uncommon = {},
        rare = {},
        event_enemy = {},
    }
    for path in pairs(self.info.script_chunks or {}) do
        local id = path:match("^scripts/battle/enemies/(.+)$")
        if id
            and id ~= "event_anchor"
            and id ~= "miss_mizzle"
            and Registry.getEnemy(id)
        then
            local success, enemy = pcall(Registry.createEnemy, id)
            if success and enemy then
                local rarity = self:normalizeRarity(enemy.rarity)
                -- "event" used to be an enemy rarity. Keep third-party or stale
                -- enemy definitions compatible with its new name.
                if rarity == "event" then rarity = "event_enemy" end
                table.insert(pools[rarity], id)
            end
        end
    end
    for _, pool in pairs(pools) do table.sort(pool) end
    self.enemy_pools = pools
    return pools
end

function Mod:pickEnemyForRarity(rarity, fallback, seed)
    rarity = self:normalizeRarity(rarity)
    local pools = self:getEnemyPools()
    local pool = pools[rarity]

    if not pool or #pool == 0 then
        if not self.warned_empty_enemy_pools then self.warned_empty_enemy_pools = {} end
        if not self.warned_empty_enemy_pools[rarity] then
            self.warned_empty_enemy_pools[rarity] = true
            Kristal.Console:warn("No "..rarity.." enemies are defined; using the common pool.")
        end
        pool = pools.common
    end

    if pool and #pool > 0 then
        local index
        if seed then
            index = (math.floor(seed) % #pool) + 1
        else
            index = love.math.random(1, #pool)
        end
        return pool[index]
    end
    return fallback
end

function Mod:pickEnemyForPhase(index, fallback, next_battle)
    next_battle = next_battle or self:getNextBattle()
    index = math.max(1, math.floor(tonumber(index) or 1))
    local rarity = next_battle.phases[index] or "common"
    -- Event phases use an inert anchor, never an enemy from a rarity pool.
    if rarity == "event" then return "event_anchor" end
    local seed = self:getPhaseSeed(next_battle.seed, index)
    local enemy_id = self:pickEnemyForRarity(rarity, fallback, seed)
    if self:isMizzleSecretActive() and enemy_id == "watercooler" then
        return "miss_mizzle"
    end
    return enemy_id
end

function Mod:pickEnemyForCurrentPhase(fallback)
    return self:pickEnemyForPhase(1, fallback)
end

function Mod:getEventPool()
    if self.event_pool then return self.event_pool end
    local pool = {}
    for path in pairs(self.info.script_chunks or {}) do
        if path:match("^scripts/battle/events/[^/]+$") then
            local success, event = pcall(modRequire, path:gsub("/", "."))
            if success and type(event) == "table" and type(event.id) == "string" then
                pool[event.id] = event
            else
                Kristal.Console:warn("Skipping invalid battle event: " .. path)
            end
        end
    end
    self.event_pool = pool
    return pool
end

function Mod:pickEventForPhase(index, next_battle)
    next_battle = next_battle or self:getNextBattle()
    local events, ids = self:getEventPool(), {}
    for id in pairs(events) do table.insert(ids, id) end
    table.sort(ids)
    if #ids == 0 then return nil end
    local seed = self:getPhaseSeed(next_battle.seed, index)
    return events[ids[(seed % #ids) + 1]]
end

function Mod:processNetworkPlayer(player, uuid)
    if type(player) ~= "table" then return end
    uuid = uuid or player.uuid

    if player.anotherdoor_next_battle_seed
        and self:isPartyHostPacket(player, uuid)
    then
        self:setNextBattleSeed(player.anotherdoor_next_battle_seed)
    end

    if player.anotherdoor_round_number
        and self:isPartyHostPacket(player, uuid)
    then
        self:setRound(player.anotherdoor_round_number, false)
    end

    if player.anotherdoor_round_total ~= nil then
        self:receiveRoundState({
            uuid = uuid,
            total = player.anotherdoor_round_total,
            active = player.anotherdoor_round_active,
            actor_id = player.anotherdoor_round_actor or player.actor,
            party_number = player.party_number,
            money = player.anotherdoor_money,
            health = type(player.health) == "table" and player.health[1],
            max_health = type(player.health) == "table" and player.health[2],
            tension = player.anotherdoor_tension_value,
            tension_max = player.anotherdoor_tension_max,
            token = player.anotherdoor_token,
        })
    end

    local battle = Game and Game.battle
    if not battle then return end

    if player.anotherdoor_money ~= nil and battle.receiveMoneyState then
        battle:receiveMoneyState({
            uuid = uuid,
            encounter = player.encounter,
            money = player.anotherdoor_money,
        })
    end

    if player.anotherdoor_card_seed and battle.receiveCardDeal then
        battle:receiveCardDeal({
            uuid = uuid,
            party_number = player.party_number,
            encounter = player.encounter,
            round = player.anotherdoor_card_round,
            battle_seed = player.anotherdoor_battle_seed,
            seed = player.anotherdoor_card_seed,
            total = player.anotherdoor_card_total,
        })
    end
    if player.anotherdoor_card_choice and battle.receiveCardSelection then
        battle:receiveCardSelection({
            uuid = uuid,
            encounter = player.encounter,
            round = player.anotherdoor_card_round,
            choice = player.anotherdoor_card_choice,
        })
    end
    if player.anotherdoor_tension_value and battle.receiveTensionState then
        battle:receiveTensionState({
            uuid = uuid,
            encounter = player.encounter,
            value = player.anotherdoor_tension_value,
            max = player.anotherdoor_tension_max,
        })
    end
end

function Mod:installNetworkHook()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.parseServerData or gcsn._anotherdoor_sync_hook_v5 then
        return
    end
    gcsn._anotherdoor_sync_hook_v5 = true

    Utils.hook(gcsn, "sendToServer", function(orig, message, ...)
        if type(message) == "table"
            and message.command == "battle"
            and message.subCommand == "update"
            and Game
            and Game.battle
        then
            local battle = Game.battle
            local player = battle.party and battle.party[1]
            local tension = player and player.chara and player.chara.tension
            message.anotherdoor_card_round = battle.card_round
            message.anotherdoor_battle_seed = battle.card_battle_seed
            message.anotherdoor_card_seed = battle.card_deal_seed
            message.anotherdoor_card_total = battle.card_phase_total
            message.anotherdoor_card_choice = battle.card_selections
                and battle.card_selections.__local
            message.anotherdoor_tension_value = tension and tension.value
            message.anotherdoor_tension_max = tension and tension.max
            message.anotherdoor_money = Mod:getLocalMoney()
        end

        if type(message) == "table"
            and message.command ~= "chat"
            and Game
            and Game.started
        then
            local party = Game.party and Game.party[1]
            message.anotherdoor_round_total = Mod:getRoundTotal()
            message.anotherdoor_round_number = Mod:getRound()
            message.anotherdoor_round_active = Mod:isRoundActive() and 1 or 0
            message.anotherdoor_round_actor = party and party.id
            message.anotherdoor_token = Mod:getToken()
        end

        if type(message) == "table"
            and message.command ~= "chat"
            and Mod:isLocalPartyHost()
            and Game
            and Game.started
        then
            local next_battle = Mod:getNextBattle()
            message.anotherdoor_next_battle_seed = next_battle.seed
        end
        return orig(message, ...)
    end)

    Utils.hook(gcsn, "parseServerData", function(orig, network, data, ...)
        if type(data) == "table" then
            if data.command == "chat" then
                local message = tostring(data.message or "")
                local encounter, round, seed, total, battle_seed = message:match(
                    "^%[anotherdoor_card_deal%]%s+(%S+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)$"
                )
                if encounter then
                    local gcsn = rawget(_G, "GCSN")
                    Mod.party_host_uuid = data.uuid
                    Mod.party_host_is_local = gcsn
                        and tostring(data.uuid or "") == tostring(gcsn.uuid or "")
                    if Game.battle and Game.battle.receiveCardDeal then
                        Game.battle:receiveCardDeal({
                            uuid = data.uuid,
                            party_number = 1,
                            encounter = encounter,
                            round = round,
                            seed = seed,
                            total = total,
                            battle_seed = battle_seed,
                        })
                    end
                    return
                end

                local choice_encounter, choice_round, choice = message:match(
                    "^%[anotherdoor_card_choice%]%s+(%S+)%s+(%d+)%s+(%d+)$"
                )
                if choice_encounter then
                    if Game.battle and Game.battle.receiveCardSelection then
                        Game.battle:receiveCardSelection({
                            uuid = data.uuid,
                            encounter = choice_encounter,
                            round = choice_round,
                            choice = choice,
                        })
                    end
                    return
                end

                local text_encounter, text_round, text_serial = message:match(
                    "^%[anotherdoor_text_ready%]%s+(%S+)%s+(%d+)%s+(%d+)$"
                )
                if text_encounter then
                    if Game.battle and Game.battle.receiveAllTextReady then
                        Game.battle:receiveAllTextReady({
                            uuid = data.uuid,
                            encounter = text_encounter,
                            round = text_round,
                            serial = text_serial,
                        })
                    end
                    return
                end

                local world_text_id = message:match(
                    "^%[anotherdoor_world_text_ready%]%s+(%S+)$"
                )
                if world_text_id then
                    Mod:markWorldTextReady(world_text_id, data.uuid)
                    return
                end

                local claim_encounter, claim_round, claim_token = message:match(
                    "^%[anotherdoor_token_claim%]%s+(%S+)%s+(%d+)%s+(%S+)$"
                )
                if claim_encounter then
                    if Game.battle and Game.battle.receiveEventTokenClaim then
                        Game.battle:receiveEventTokenClaim({
                            uuid = data.uuid,
                            encounter = claim_encounter,
                            round = claim_round,
                            token = claim_token,
                        })
                    end
                    return
                end

                local token_encounter, token_round, token_owner,
                    token_id = message:match(
                    "^%[anotherdoor_token_pick%]%s+(%S+)%s+(%d+)%s+(%S+)%s+(%S+)$"
                )
                if token_encounter then
                    if Game.battle and Game.battle.receiveEventTokenSelection then
                        Game.battle:receiveEventTokenSelection({
                            sender_uuid = data.uuid,
                            owner_uuid = token_owner,
                            encounter = token_encounter,
                            round = token_round,
                            token = token_id,
                        })
                    end
                    return
                end

                local reject_encounter, reject_round, reject_owner,
                    reject_token = message:match(
                    "^%[anotherdoor_token_reject%]%s+(%S+)%s+(%d+)%s+(%S+)%s+(%S+)$"
                )
                if reject_encounter then
                    if Game.battle and Game.battle.receiveEventTokenRejection then
                        Game.battle:receiveEventTokenRejection({
                            sender_uuid = data.uuid,
                            owner_uuid = reject_owner,
                            encounter = reject_encounter,
                            round = reject_round,
                            token = reject_token,
                        })
                    end
                    return
                end

                local tension_encounter, tension_value, tension_max = message:match(
                    "^%[anotherdoor_tension%]%s+(%S+)%s+([%d%.%-]+)%s+([%d%.%-]+)$"
                )
                if tension_encounter then
                    if Game.battle and Game.battle.receiveTensionState then
                        Game.battle:receiveTensionState({
                            uuid = data.uuid,
                            encounter = tension_encounter,
                            value = tension_value,
                            max = tension_max,
                        })
                    end
                    return
                end

                local status_encounter, bite, poison = message:match(
                    "^%[anotherdoor_status%]%s+(%S+)%s+(%d+)%s+(%d+)$"
                )
                if status_encounter then
                    if Game.battle and Game.battle.receiveStatusState then
                        Game.battle:receiveStatusState({
                            uuid = data.uuid,
                            encounter = status_encounter,
                            bite = bite,
                            poison = poison,
                        })
                    end
                    return
                end

                local resurrection_encounter, resurrection_round,
                    resurrection_serial, resurrection_max = message:match(
                    "^%[anotherdoor_resurrection%]%s+(%S+)%s+(%d+)%s+(%d+)%s+(%d+)$"
                )
                if resurrection_encounter then
                    if Game.battle and Game.battle.receiveResurrectionState then
                        Game.battle:receiveResurrectionState({
                            uuid = data.uuid,
                            encounter = resurrection_encounter,
                            round = resurrection_round,
                            serial = resurrection_serial,
                            max_health = resurrection_max,
                        })
                    end
                    return
                end

                local money_encounter, money = message:match(
                    "^%[anotherdoor_money%]%s+(%S+)%s+(%d+)$"
                )
                if money_encounter then
                    if Game.battle and Game.battle.receiveMoneyState then
                        Game.battle:receiveMoneyState({
                            uuid = data.uuid,
                            encounter = money_encounter,
                            money = money,
                        })
                    end
                    return
                end

                local door_seed = message:match(
                    "^%[anotherdoor_door_ready%]%s+(%d+)$"
                )
                if door_seed then
                    Mod:markDoorReady(door_seed, data.uuid)
                    return
                end

                local intro_actor = message:match(
                    "^%[anotherdoor_intro_ready%]%s+(%S+)$"
                )
                if intro_actor then
                    Mod:markIntroReady(data.uuid, intro_actor)
                    return
                end

                local highlight_actor, highlight_party = message:match(
                    "^%[anotherdoor_intro_highlight%]%s+(%S+)%s+(%d+)$"
                )
                if highlight_actor then
                    Mod:markIntroHighlight(
                        data.uuid,
                        highlight_actor,
                        highlight_party
                    )
                    return
                end

                local round_total, round_active, round_money,
                    round_health, round_max_health, round_tension,
                    round_tension_max, round_bite, round_poison,
                    round_token = message:match(
                    "^%[anotherdoor_round%]%s+(%d+)%s+([01])%s+(%d+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+(%d+)%s+(%d+)%s+(%S+)$"
                )
                if not round_total then
                    round_total, round_active, round_money,
                        round_health, round_max_health, round_tension,
                        round_tension_max, round_bite, round_poison = message:match(
                        "^%[anotherdoor_round%]%s+(%d+)%s+([01])%s+(%d+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)%s+(%d+)%s+(%d+)$"
                    )
                end
                if not round_total then
                    round_total, round_active = message:match(
                        "^%[anotherdoor_round%]%s+(%d+)%s+([01])$"
                    )
                end
                if round_total then
                    Mod:receiveRoundState({
                        uuid = data.uuid,
                        total = round_total,
                        active = round_active,
                        money = round_money,
                        health = round_health,
                        max_health = round_max_health,
                        tension = round_tension,
                        tension_max = round_tension_max,
                        bite = round_bite,
                        poison = round_poison,
                        token = round_token,
                    })
                    return
                end

                local reset_round = message:match(
                    "^%[anotherdoor_round_reset%]%s+(%d+)$"
                )
                if reset_round or message == "[anotherdoor_round_reset]" then
                    if Mod:isPartyHostPacket(data, data.uuid) then
                        Mod.round_reset_target = tonumber(reset_round)
                            or (Mod:getRound() + 1)
                        Mod:requestRoundReset(false, false)
                    end
                    return
                end

                local next_seed, mizzle_secret, double_effect = message:match(
                    "^%[anotherdoor_next_battle%]%s+(%d+)%s+(%d+)%s+(%d+)$"
                )
                if not next_seed then
                    next_seed, mizzle_secret = message:match(
                    "^%[anotherdoor_next_battle%]%s+(%d+)%s+(%d+)$"
                    )
                end
                if not next_seed then
                    next_seed = message:match(
                        "^%[anotherdoor_next_battle%]%s+(%d+)$"
                    )
                end
                if next_seed then
                    if Mod:isPartyHostPacket(data, data.uuid) then
                        if mizzle_secret ~= nil then
                            Mod:setMizzleSecret(mizzle_secret == "1", false)
                        end
                        if double_effect ~= nil then
                            Mod:setDoubleEffectBattles(
                                tonumber(double_effect) or 0,
                                false
                            )
                        end
                        Mod:setNextBattleSeed(next_seed)
                    end
                    -- Control messages are never forwarded to GCSN's chat UI.
                    return
                end
            end

            Mod:processNetworkPlayer(data, data.uuid)
            if type(data.players) == "table" then
                for key, player in pairs(data.players) do
                    Mod:processNetworkPlayer(player, player.uuid or key)
                end
            end
        end
        return orig(network, data, ...)
    end)
end

function Mod:init()
    self:installNetworkHook()
    self.enemy_pools = nil
    self.event_pool = nil
    self.intro_ready = {}
    self.intro_highlights = {}
    self.world_text_ready = {}
    print("Loaded " .. self.info.name .. "!")

    Game:registerEvent("mouseholeentry", function(data)
        return MouseholeEntry(data.x, data.y, { data.width, data.height })
    end)

    Game:registerEvent("nextscreen", function(data)
        return nextscreen(data.x, data.y, { data.width, data.height })
    end)

    Game:registerEvent("rune_rounds", function(data)
        return rune_rounds(
            data.x,
            data.y,
            {data.width, data.height}
        )
    end)

    Game:registerEvent("climbshooter", function(data)
        -- timer_offset is a custom property! Let's read it here and pass it into our object.
        -- Same with shoot_speed.
        return ClimbShooter(data.x, data.y, { data.width, data.height }, data.properties.timer_offset, data.properties.shoot_speed)
    end)
end

function Mod:postInit()
    self:installNetworkHook()
end

function Mod:update()
    self:installNetworkHook()
    if Game and Game.started then
        local member = Game.party and Game.party[1]
        if member then
            member.active = self:isRoundActive()
            if member.active
                and not member.anotherdoor_resurrecting
                and member:getHealth() <= 0
            then
                if Game.battle and Game.battle.handleLocalRoundDeath then
                    Game.battle:handleLocalRoundDeath()
                else
                    self:markLocalDeath()
                end
            end
        end
        self:syncRoundState()
        self:checkLoverPartner()
        self:updateSpectating()
        if self.round_reset_pending
            and self.round_reset_waiting_for_host
            and (not self:isPartyOnline() or self:isLocalPartyHost())
        then
            self.round_reset_waiting_for_host = false
            self:broadcastRoundReset()
            if not Game.battle then self:completeRoundReset() end
        end
        if not self:isRoundActive() and not self.round_reset_pending then
            self:areAllRoundPlayersInactive()
        end
        self:updateDoubleEffectWorldMusic()
        self:startPendingPostBattleEvent()
    end
end
