---@class SnapshotSliceTransition : Object
local SnapshotSliceTransition, super = Class(Object)

local LINE_ANIMATION_TIME = 1
local PART_TIME = 0.7
local LINE_START_WIDTH = 50
local LINE_END_WIDTH = 1

local function easeInOut(progress)
    return progress * progress * (3 - (2 * progress))
end

local function easeOut(progress)
    return 1 - ((1 - progress) ^ 3)
end

function SnapshotSliceTransition:init()
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self:setParallax(0, 0)
    self.layer = WORLD_LAYERS["top"]

    -- This is an in-memory copy of the last rendered frame. Unlike
    -- love.graphics.captureScreenshot, it never writes anything to disk.
    self.snapshot = love.graphics.newImage(SCREEN_CANVAS:newImageData())
    self.snapshot:setFilter("nearest", "nearest")
    self.left_quad = love.graphics.newQuad(
        0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT,
        SCREEN_WIDTH, SCREEN_HEIGHT
    )
    self.right_quad = love.graphics.newQuad(
        SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT,
        SCREEN_WIDTH, SCREEN_HEIGHT
    )

    self.timer = 0
    self.finished = false
    self.completion_called = false
    self.on_complete = nil
    self.swing_played = false
    Assets.playSound("criticalswing")
end

function SnapshotSliceTransition:isDone()
    return self.finished
end

function SnapshotSliceTransition:update()
    self.timer = self.timer + DT
    local part_start = LINE_ANIMATION_TIME
    if self.timer >= part_start and not self.swing_played then
        self.swing_played = true
        Assets.playSound("locker")
    end
    local total = part_start + PART_TIME
    self.finished = self.timer >= total
    super.update(self)
    if self.finished and not self.completion_called then
        self.completion_called = true
        if self.on_complete then
            self.on_complete()
        end
    end
end

function SnapshotSliceTransition:getPartProgress()
    local start = LINE_ANIMATION_TIME
    return MathUtils.clamp((self.timer - start) / PART_TIME, 0, 1)
end

function SnapshotSliceTransition:drawSnapshot()
    local progress = easeOut(self:getPartProgress())
    local distance = (SCREEN_WIDTH / 2) + 24
    local left_x = -distance * progress
    local right_x = (SCREEN_WIDTH / 2) + (distance * progress)

    Draw.setColor(COLORS.white)
    love.graphics.draw(self.snapshot, self.left_quad, left_x, 0)
    love.graphics.draw(self.snapshot, self.right_quad, right_x, 0)
end

function SnapshotSliceTransition:drawCutLine()
    if self.timer < LINE_ANIMATION_TIME then
        local progress = easeOut(MathUtils.clamp(
            self.timer / LINE_ANIMATION_TIME,
            0,
            1
        ))
        local length = SCREEN_HEIGHT * progress
        local width = MathUtils.lerp(
            LINE_START_WIDTH,
            LINE_END_WIDTH,
            progress
        )
        love.graphics.push()
        love.graphics.translate(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
        love.graphics.rotate((math.pi / 2) * progress)
        Draw.setColor(1, 1, 1, progress)
        love.graphics.rectangle(
            "fill",
            -length / 2,
            -width / 2,
            length,
            width
        )
        love.graphics.pop()
    else
        local alpha = 1 - self:getPartProgress()
        Draw.setColor(1, 1, 1, alpha)
        love.graphics.rectangle(
            "fill",
            (SCREEN_WIDTH - LINE_END_WIDTH) / 2,
            0,
            LINE_END_WIDTH,
            SCREEN_HEIGHT
        )
    end
end

function SnapshotSliceTransition:draw()
    self:drawSnapshot()
    self:drawCutLine()
    super.draw(self)
end

return SnapshotSliceTransition
