local Dummy, super = Class(Encounter)

function Dummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battle" is rude buster)
    self.music = "battle"
    -- Enables the purple grid battle background
    self.background = true

    -- Draw from the pool matching the first phase shown by Nextscreen.
    self:addEnemy(Mod:pickEnemyForCurrentPhase("dummy"))

    --- Uncomment this line to add another!
    --self:addEnemy("dummy")
end

return Dummy
