extends Label


func _process(_delta: float) -> void:
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
	if bc.selected_hub:
		for comp in bc.selected_hub.get_hub_components():
			if comp is InfluenceSender:
				$".".text += "SEND VAL  = " + str(comp.get_send_value())
