extends Label


func _process(delta: float) -> void:
	var bc : BattleController
	bc = $"../.."
	if bc._cur_mode == bc.STATE.Idle:
		$".".text = "IDLE"
	elif bc._cur_mode == bc.STATE.HubSelected:
		$".".text = "HUB SELECTED"
	else:
		$".".text = "TARGET MODE"
