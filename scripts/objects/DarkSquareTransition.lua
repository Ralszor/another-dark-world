---@class DarkSquareTransition : Object
local DarkSquareTransition, super = Class(Object)

local DURATION_FRAMES = 80
local SOUND_THRESHOLD = 6
local RECT_AMOUNT = 6

function DarkSquareTransition:init()
    super.init(self, 0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    self:setScale(2, 2)
    self:setParallax(0, 0)
    self.layer = (Game.fader and Game.fader.layer or WORLD_LAYERS["top"]) + 200
    self.persistent = true
    self.texture = Assets.getTexture("kristal/doorblack")
    self.sound = Assets.newSound("dtrans_square")
    -- These are deliberately measured in Kristal frames, matching
    -- DarkTransition's con == 16 section exactly.
    self.timer = 0
    self.soundtimer = 3
    self.rectsound = 0
    self.rs = 0
    self.sizes = {}
    for index = 1, 8 do
        self.sizes[index] = 1 + ((index - 1) * -2)
    end
    self.covered = false
end

function DarkSquareTransition:isCovered()
    return self.covered
end

function DarkSquareTransition:update()
    if not self.covered then
        self.soundtimer = self.soundtimer + DTMULT
        if self.soundtimer >= SOUND_THRESHOLD
            and self.rectsound < RECT_AMOUNT
        then
            self.soundtimer = 0
            self.sound:stop()
            self.sound:setVolume(0.5)
            self.sound:play()
            self.rectsound = self.rectsound + 1
        end

        self.timer = self.timer + DTMULT
        if self.timer >= DURATION_FRAMES then
            self.timer = 0
            self.covered = true
        end
    end
    super.update(self)
end

function DarkSquareTransition:drawSquare(size)
    local darkness = 5 - (size * 0.8)
    if self.rs < 20 then darkness = darkness * (self.rs / 20) end
    darkness = MathUtils.clamp(darkness, 0, 1)
    Draw.setColor(darkness, darkness, darkness, 1)
    Draw.draw(
        self.texture,
        SCREEN_WIDTH / 4,
        91,
        -math.rad(size),
        0.44 * size,
        0.54 * size,
        self.texture:getWidth() / 2,
        self.texture:getHeight() / 2
    )
end

function DarkSquareTransition:draw()
    if self.covered then
        Draw.setColor(COLORS.black)
        love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    else
        -- DarkTransition advances these values in draw(), not update().
        self.rs = self.rs + DTMULT
        for index = 1, RECT_AMOUNT do
            self.sizes[index] = self.sizes[index] + (0.25 * DTMULT)
            if self.sizes[index] > 0 then self:drawSquare(self.sizes[index]) end
        end
    end
    super.draw(self)
end

function DarkSquareTransition:onRemove(parent)
    self.sound:stop()
    super.onRemove(self, parent)
end

return DarkSquareTransition
