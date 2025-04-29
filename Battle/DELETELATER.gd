extends Label


func _process(delta: float) -> void:
	var bc : BattleController
	bc = $"../.."
	match bc._cur_mode:
		bc.STATE.Idle:
			$".".text = "IDLE"
		bc.STATE.HubSelected:
			$".".text = "HUB SELECTED"
		bc.STATE.TargetSelection:
			$".".text = "TARGET MODE"
		#bc.STATE.DragSelection:
			#$".".text = "DragSelection"
		_:
			$".".text = "???????"
