return {
    event = function(cutscene)
        local battle = Game.battle
        cutscene:textAll("text 1")
        cutscene:textAll("text 1")
        cutscene:textAll("text 1")

        battle:showTokenSelection()
        cutscene:wait(function()
            return battle.token_selection_object
                and battle.token_selection_object.alpha >= 1
        end)

        local member = battle:getTokenEventPromptMember()
        local name = member and member.name or "PLAYER"
        local color = member and member.soul_color or COLORS.red
        cutscene:textAll(
            "[color:" .. Utils.rgbToHex(color) .. "]" .. name
                .. ",[color:white] pick one!"
        )

        battle:enableTokenSelection()
        cutscene:wait(function()
            return battle:hasEveryEventTokenSelection()
                and battle.token_selection_object
                and battle.token_selection_object:isPickAnimationDone()
        end)
        battle:endTokenSelectionEvent()
    end,
}
