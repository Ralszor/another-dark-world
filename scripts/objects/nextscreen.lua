---@class nextscreen : Event
local nextscreen, super = Class(Event)

function nextscreen:init(x, y, shape)
    super.init(self, x, y, shape)
    self.phase_sprites = {}
    self.phase_signature = nil
    Mod:installNetworkHook()
    Mod:syncNextBattleFlag(true)
    self:refreshPhases()
end

function nextscreen:refreshPhases()
    for _, sprite in ipairs(self.phase_sprites) do
        sprite:remove()
    end
    self.phase_sprites = {}

    local phases = Mod:getPhaseQueue()
    self.phase_signature = table.concat(phases, ":")
        .. ":" .. (Mod:isMizzleSecretActive() and "normal" or "normal")

    local scale = 2
    local icon_width = 24 * scale
    local gap = 1
    local row_count = math.ceil(#phases / 3)
    local rows_height = (row_count * icon_width) + (math.max(row_count - 1, 0) * gap)
    local start_y = (self.height - rows_height) / 2
    for index, rarity in ipairs(phases) do
        local row = math.floor((index - 1) / 3)
        local index_in_row = (index - 1) % 3
        local remaining = #phases - (row * 3)
        local columns = math.min(3, remaining)
        local row_width = (columns * icon_width) + ((columns - 1) * gap)
        local start_x = (self.width - row_width) / 2
        local icon_names = {
            common = "monster",
            uncommon = "monster",
            rare = "monster",
            event_enemy = "monster",
            event = "event",
        }
        local enemy_id = Mod:pickEnemyForPhase(index, nil)
        local path = enemy_id == "miss_mizzle"
            and "ui/mizzle"
            or "ui/" .. (icon_names[rarity] or rarity)
        local sprite = Sprite(
            path,
            start_x + (index_in_row * (icon_width + gap)),
            start_y + (row * (icon_width + gap))
        )
        sprite:setScale(scale)
        sprite:setAnimation({path, 0.25, true})
        self:addChild(sprite)
        table.insert(self.phase_sprites, sprite)
    end
end

function nextscreen:update()
    super.update(self)
    Mod:installNetworkHook()
    Mod:syncNextBattleFlag()
    local signature = table.concat(Mod:getPhaseQueue(), ":")
        .. ":" .. (Mod:isMizzleSecretActive() and "normal" or "normal")
    if signature ~= self.phase_signature then
        self:refreshPhases()
    end
end

function nextscreen:onInteract(player, dir)
    Assets.playSound("squeak")
    return true
end

function nextscreen:draw()
    super.draw(self)
    love.graphics.setFont(Assets.getFont("small"))
    love.graphics.printf("UP NEXT", 0, 16, self.width,"center")
end

return nextscreen
