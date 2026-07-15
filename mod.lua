local function installCardSelectionHook()
    local gcsn = rawget(_G, "GCSN")
    if not gcsn or not gcsn.parseServerData or gcsn._anotherdoor_card_hook then
        return
    end

    gcsn._anotherdoor_card_hook = true
    Utils.hook(gcsn, "sendToServer", function(orig, message, ...)
        if type(message) == "table"
            and message.command == "battle"
            and message.subCommand == "update"
            and Game.battle
            and Game.battle.card_selections
        then
            message.anotherdoor_card_round = Game.battle.card_round
            message.anotherdoor_card_seed = Game.battle.card_deal_seed
            if Game.battle.card_selections.__local then
                message.anotherdoor_card_choice = Game.battle.card_selections.__local
            end
        end
        return orig(message, ...)
    end)

    Utils.hook(gcsn, "parseServerData", function(orig, network, data, ...)
        if type(data) == "table" and data.command == "chat" then
            local message = tostring(data.message or "")
            local encounter, round, seed = message:match(
                "^%[anotherdoor_card_deal%]%s+(%S+)%s+(%d+)%s+(%d+)%s+%d+$"
            )
            if encounter then
                if Game.battle and Game.battle.receiveCardDeal then
                    Game.battle:receiveCardDeal({
                        uuid = data.uuid,
                        party_number = 1,
                        encounter = encounter,
                        round = round,
                        seed = seed,
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
        end

        if type(data) == "table"
            and data.command == "battle"
            and data.subCommand == "anotherdoor_card_choice"
        then
            if Game.battle and Game.battle.receiveCardSelection then
                local selections = data.players or {data}
                for _, selection in ipairs(selections) do
                    Game.battle:receiveCardSelection(selection)
                end
            end
            return
        end

        if type(data) == "table"
            and (data.command == "battle" or data.command == "battle_update")
            and (data.subCommand == "update" or data.command == "battle_update")
            and Game.battle
            and Game.battle.receiveCardSelection
        then
            local players = data.players or {data}
            for _, player in ipairs(players) do
                if player.anotherdoor_card_seed and Game.battle.receiveCardDeal then
                    Game.battle:receiveCardDeal({
                        uuid = player.uuid,
                        party_number = player.party_number,
                        encounter = player.encounter,
                        round = player.anotherdoor_card_round,
                        seed = player.anotherdoor_card_seed,
                    })
                end
                if player.anotherdoor_card_choice then
                    Game.battle:receiveCardSelection({
                        uuid = player.uuid,
                        encounter = player.encounter,
                        round = player.anotherdoor_card_round,
                        choice = player.anotherdoor_card_choice,
                    })
                end
            end
        end

        return orig(network, data, ...)
    end)
end

function Mod:init()
    installCardSelectionHook()

    Game:registerEvent("squeak", function(data)
        return Squeak(data.x, data.y, {data.width, data.height, data.polygon})
    end)
    print("Loaded " .. self.info.name .. "!")
end

function Mod:postInit()
    installCardSelectionHook()
end

function Mod:unload()
    local gcsn = rawget(_G, "GCSN")
    if gcsn then
        gcsn._anotherdoor_card_hook = nil
    end
end
