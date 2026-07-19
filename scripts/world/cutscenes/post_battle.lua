return {
    double_effect = function(cutscene, battle_seed, duration)
        duration = math.max(2, math.floor(tonumber(duration) or 2))
        cutscene:textAll(
            "* [color:red]DOUBLE EFFECT[color:reset] will affect the next "
                .. tostring(duration)
                .. " battles.",
            nil,
            nil,
            {
                sync_id = "double_effect_"
                    .. tostring(battle_seed)
                    .. "_"
                    .. tostring(duration),
            }
        )
    end,
}
