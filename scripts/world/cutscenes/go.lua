return {
    intro = function(cutscene)
        Game.lock_movement = true
        local snapshot = SnapshotSliceTransition()
        Game.world:addChild(snapshot)

        
        -- The world fader is below the snapshot's layer, so only the real world
        -- fades out while the captured frame performs the cut.
        cutscene:fadeOut(0.5)
        cutscene:wait(1)
        local bg = GonerBackground()
        bg.layer = Game.fader.layer+0.01
        Game.world:addChild(bg)
        cutscene:wait(function()
            return snapshot:isDone()
        end)
        snapshot:remove()
        
        cutscene:wait(5)

        local current_text

        local function gonerTextFade(wait)
            local this_text = current_text
            if not this_text then
                return
            end
            Game.world.timer:tween(1, this_text, { alpha = 0 }, "linear", function ()
                this_text:remove()
                if current_text == this_text then
                    current_text = nil
                end
            end)
            if wait ~= false then
                cutscene:wait(1)
            end
        end

        local function gonerText(str, advance)
            current_text = DialogueText("[speed:0.3][spacing:6][style:GONER][voice:none]" .. str, 160, 100, 640, 480,
                                        { auto_size = true })
            current_text.layer = WORLD_LAYERS["top"] + 100
            current_text.skip_speed = true
            current_text.parallax_x = 0
            current_text.parallax_y = 0
            Game.world:addChild(current_text)

            if advance ~= false then
                local this_text = current_text
                cutscene:wait(function () return not this_text:isTyping() end)
                gonerTextFade(true)
            end
        end
        local spr = Sprite("player/heart_blur")
        spr:setOrigin(0.5)
        spr:setParallax(0)
        spr:setScale(2)
        Game.world:addChild(spr)
        spr.x, spr.y = SCREEN_WIDTH/2, SCREEN_HEIGHT/2+50
        spr.alpha = 0
        spr.layer = Game.fader.layer + 100
        local siner = 0
        cutscene:during(function()
        siner = siner + DTMULT/30
            spr.y = spr.y + (math.sin(siner*2)/2)
        end)
        gonerText("ARE YOU HERE?[wait:20]")
        gonerText("ARE WE\n[wait:20]CONNECTED?[wait:20]")
        gonerText("I AM MOST CERTAIN [wait:20]\nTHIS CONNECTION MAY\nCUT SHORT.[wait:20]")
        Game.world.timer:tween(1, spr, {alpha = 1})
        cutscene:wait(1)
        gonerText("I PROPOSE TO YOU\n[wait:20]AN OPPORTUNITY.[wait:20]")
        gonerText("I WILL GIVE YOU\n[wait:20]A BODY.[wait:20]")
        gonerText("YOUR VESSEL\nIS NOT FEASIBLE\nFOR THE TASK.[wait:20]")
        gonerText("THAT TASK,\n[wait:20]TO REVERT.[wait:20]")
        gonerText("TO REVERT[wait:20]\nMY FAILED EXPERIMENT.[wait:20]")
        cutscene:wait(1)
        gonerText("IT IS NOT NEGOTIABLE.[wait:20]")

        local selector = PartyMemberSelector()
        Game.world:addChild(selector)
        spr:slideTo(SCREEN_WIDTH/2, SCREEN_HEIGHT - 70, 1,'in-out-cubic')
        cutscene:wait(function()
            return selector:isConfirmed()
        end)
        local selected_member = selector:getSelectedMember()

        local selected_id = selected_member and selected_member.id
            or (Game.party and Game.party[1] and Game.party[1].id)
            or "vessel"
        Mod:syncIntroReady(selected_id, true)
        cutscene:wait(function()
            Mod:syncIntroReady(selected_id)
            return Mod:areIntroPlayersReady()
        end)

        gonerText("EXCELLENT.[wait:20]")
        cutscene:wait(0.35)
        selector:fadeOut(0.6)
        Game.world.timer:tween(0.6, spr, {alpha = 0}, "out-quad")
        bg.music:fade(0, 2)
        cutscene:wait(3)
        selector:remove()

        local square_transition = DarkSquareTransition()
        Game.stage:addChild(square_transition)
        cutscene:wait(function() return square_transition:isCovered() end)
        if selected_member then
            Game:setPartyMembers(selected_member)
        end
        Game:setFlag("triggered_intro", true)
        Game:setFlag("triggered_intro_complete", true)
        cutscene:loadMap("room2")

        -- Match Battle:returnToWorld(): only the local party authority rolls
        -- the next queue, then sends that seed to every online client.
        local gcsn = rawget(_G, "GCSN")
        local can_refresh_seed = not Mod:isPartyOnline()
            or Mod.party_host_is_local
            or Mod:isLocalPartyHost()
        if can_refresh_seed then
            Mod:advancePhaseQueue()
            if gcsn then
                Mod:syncNextBattleFlag(true, true)
            end
        end
        bg.music:stop()
        bg:remove()
        square_transition:remove()
        Game.lock_movement = false
        cutscene:wait(cutscene:fadeIn(0.5, {music = false}))
    end,
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
        cutscene:wait(cutscene:fadeIn())
        Mod:runPendingPostBattleEvent(cutscene)
    end,
    cashout = function(cutscene)
        local menu = DarkMenu()
        Game.world:openMenu(menu)
        local cashout = menu:startAnotherDoorCashout(Mod:getLocalMoney())
        cutscene:wait(function() return cashout.finished end)

        if cashout.round_ended then
            -- Let the completed TOTAL render once before capturing the menu.
            cutscene:wait(1 / 30)

            local snapshot = SnapshotSliceTransition()
            snapshot.layer = (Game.fader and Game.fader.layer
                or WORLD_LAYERS["top"]) + 1
            snapshot.on_complete = function()
                if snapshot.parent then snapshot:remove() end
            end
            Game.stage:addChild(snapshot)

            -- The refreshed round is prepared behind the captured cash-out
            -- screen, so the slice reveals the newly active player state.
            Game.world:closeMenu()
            if Mod.round_reset_pending
                and not Mod.round_reset_waiting_for_host
            then
                Mod:completeRoundReset()
            end

            cutscene:wait(function() return snapshot:isDone() end)
        else
            cutscene:wait(function()
                return Game.world.menu ~= menu
            end)
        end
    end
}
