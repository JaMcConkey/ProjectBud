extends Label

@onready var label: Label = $"."

func _process(_delta: float) -> void:
	var bc : BattleController
	bc = $"../.."
	var am : ActionManager
	am = bc.action_manager
	if am.pending_action != null and am.pending_action is HubAction:
		var s_hub = am.pending_action.source_hub as Hub
		#var p_hub = s_hub.hub_ui.get_active_component()
		#if p_hub is InfluenceSender:
			#text = "COST : " + str(p_hub.get_pending_cost())
		#else:
			#text = ""
	else:
		text = ""
	#match bc._cur_mode:
		#bc.STATE.Idle:
			#$".".text = "IDLE"
		#bc.STATE.HubSelected:
			#$".".text = "HUB SELECTED"
		#bc.STATE.TargetSelection:
			#$".".text = "TARGET MODE"
		##bc.STATE.DragSelection:
			##$".".text = "DragSelection"
		#_:
			#$".".text = "???????"
	#if bc.selected_hub:
		#for comp in bc.selected_hub.get_hub_components():
			#if comp is InfluenceSender:
				#$".".text += "SEND VAL  = " + str(comp.pending_send_val)
