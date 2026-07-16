return {
    nextdoor = function(cutscene, event)
        if not Mod:isRoundActive() then
            return
        end
        local next_battle = Mod:getNextBattle()
        Mod:syncDoorReady(next_battle.seed, true)
        cutscene:wait(function()
            Mod:syncDoorReady(next_battle.seed)
            return Mod:areDoorPlayersReady(next_battle.seed)
        end)

        local source_x, source_y = SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2
        if event then
            source_x, source_y = event:getScreenPos()
            source_x = source_x + ((event.width or 0) / 2)
            source_y = source_y + ((event.height or 0) / 2)
        end

        local reward = MoneyRewardAnimation(source_x, source_y, next_battle)
        if not reward:isDone() then
            Game.world:addChild(reward)
            cutscene:wait(function() return reward:isDone() end)
        end

        cutscene:wait(cutscene:fadeOut())
        if reward.parent then
            reward:remove()
        end
        cutscene:startEncounter("guei")
        cutscene:fadeIn()
    end,
    cashout = function(cutscene)
        local menu = DarkMenu()
        Game.world:openMenu(menu)
        menu:startAnotherDoorCashout(Mod:getLocalMoney())
        cutscene:wait(function()
            return Game.world.menu ~= menu
        end)
    end
}
