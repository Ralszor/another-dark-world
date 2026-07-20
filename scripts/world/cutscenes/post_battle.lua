return {
    double_effect = function(cutscene, battle_seed)
        cutscene:textAll(
            "* [color:yellow]DOUBLE EFFECT[color:reset] will affect the next battle.",
            nil,
            nil,
            {
                sync_id = "double_effect_"
                    .. tostring(battle_seed)
            }
        )
    end,
}
