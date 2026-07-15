local PHASE_WEIGHTS = {
    {rarity = "common", weight = 80},
    {rarity = "uncommon", weight = 10},
    {rarity = "rare", weight = 5},
    {rarity = "event", weight = 5},
}

local VALID_RARITIES = {
    common = true,
    uncommon = true,
    rare = true,
    event = true,
}

local NEXT_BATTLE_FLAG = "another_door_next_battle"
local MAX_PHASES = 6
local SEED_MODULUS = 2147483647
local SEED_MULTIPLIER = 48271

function Mod:getLocalPartyNumber()
    local battler = Game and Game.battle and Game.battle.party
        and Game.battle.party[1]
    if battler and tonumber(battler.party_number) then
        return tonumber(battler.party_number)
    end

    local player = Game and Game.world and Game.world.player
    return player and tonumber(player.party_number)
end

function Mod:isLocalPartyHost()
    local gcsn = rawget(_G, "GCSN")
    return gcsn
        and gcsn.party_members
        and next(gcsn.party_members) ~= nil
        and self:getLocalPartyNumber() == 1
end

function Mod:isPartyHostPacket(player, uuid)
    if tonumber(player and player.party_number) == 1 then
        return true
    end

    local gcsn = rawget(_G, "GCSN")
    uuid = tostring(uuid or player and player.uuid or "")
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

function Mod:syncNextBattleFlag(force)
    self.next_battle_sync_timer = (self.next_battle_sync_timer or 0) + DT
    if not force and self.next_battle_sync_timer < 0.5 then return end
    self.next_battle_sync_timer = 0

    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.sendToServer or not self:isLocalPartyHost() then
        return
    end

    gcsn.sendToServer({
        command = "chat",
        uuid = gcsn.uuid,
        message = "[anotherdoor_next_battle] " .. tostring(self:getNextBattle().seed),
    })
end

function Mod:normalizeRarity(rarity)
    rarity = tostring(rarity or "common"):lower()
    if rarity == "events" then rarity = "event" end
    return VALID_RARITIES[rarity] and rarity or "common"
end

function Mod:rollPhaseRarity()
    return self:getRarityForRoll(love.math.random(1, 100))
end

function Mod:getRarityForRoll(roll)
    local total = 0
    for _, entry in ipairs(PHASE_WEIGHTS) do
        total = total + entry.weight
        if roll <= total then return entry.rarity end
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
        phases[index] = self:getRarityForRoll((phase_seed % 100) + 1)
    end

    local next_battle = {seed = seed, phases = phases}
    Game:setFlag(NEXT_BATTLE_FLAG, next_battle)
    return next_battle
end

function Mod:generateNextBattle()
    return self:createBattleFromSeed(love.math.random(1, SEED_MODULUS - 1))
end

function Mod:setNextBattleSeed(seed)
    seed = math.max(1, math.floor(tonumber(seed) or 1) % SEED_MODULUS)
    local current = Game:getFlag(NEXT_BATTLE_FLAG)
    if type(current) == "table" and current.seed == seed then
        return current
    end
    return self:createBattleFromSeed(seed)
end

function Mod:getNextBattle()
    local next_battle = Game:getFlag(NEXT_BATTLE_FLAG)
    if type(next_battle) == "table"
        and type(next_battle.seed) == "number"
        and type(next_battle.phases) == "table"
        and #next_battle.phases == ((next_battle.seed % MAX_PHASES) + 1)
    then
        for _, rarity in ipairs(next_battle.phases) do
            if not VALID_RARITIES[rarity] then
                return self:generateNextBattle()
            end
        end
        return next_battle
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

    local pools = {common = {}, uncommon = {}, rare = {}, event = {}}
    for path in pairs(self.info.script_chunks or {}) do
        local id = path:match("^scripts/battle/enemies/(.+)$")
        if id and Registry.getEnemy(id) then
            local success, enemy = pcall(Registry.createEnemy, id)
            if success and enemy then
                local rarity = self:normalizeRarity(enemy.rarity)
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
    local seed = self:getPhaseSeed(next_battle.seed, index)
    return self:pickEnemyForRarity(rarity, fallback, seed)
end

function Mod:pickEnemyForCurrentPhase(fallback)
    return self:pickEnemyForPhase(1, fallback)
end

function Mod:processNetworkPlayer(player, uuid)
    if type(player) ~= "table" then return end
    uuid = uuid or player.uuid

    if player.anotherdoor_next_battle_seed
        and self:isPartyHostPacket(player, uuid)
    then
        self:setNextBattleSeed(player.anotherdoor_next_battle_seed)
    end

    local battle = Game and Game.battle
    if not battle then return end

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
    if not gcsn or not gcsn.parseServerData or gcsn._anotherdoor_sync_hook_v2 then
        return
    end
    gcsn._anotherdoor_sync_hook_v2 = true

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
        end

        if type(message) == "table"
            and message.command ~= "chat"
            and Mod:isLocalPartyHost()
            and Game
            and Game.started
        then
            message.anotherdoor_next_battle_seed = Mod:getNextBattle().seed
        end
        return orig(message, ...)
    end)

    Utils.hook(gcsn, "parseServerData", function(orig, network, data, ...)
        if type(data) == "table" then
            if data.command == "chat" then
                local seed = tostring(data.message or ""):match(
                    "^%[anotherdoor_next_battle%]%s+(%d+)$"
                )
                if seed then
                    if Mod:isPartyHostPacket(data, data.uuid) then
                        Mod:setNextBattleSeed(seed)
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
    print("Loaded " .. self.info.name .. "!")

    Game:registerEvent("mouseholeentry", function(data)
        return MouseholeEntry(data.x, data.y, { data.width, data.height })
    end)

    Game:registerEvent("nextscreen", function(data)
        return nextscreen(data.x, data.y, { data.width, data.height })
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
