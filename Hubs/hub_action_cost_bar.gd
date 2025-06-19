extends Control
class_name HubActionCostBar

var _action : GameAction
@onready var progress_bar: ProgressBar = $ProgressBar


func bind_action(p_action : GameAction):
	_action = p_action
	_action.cost_updated.connect(_update_cost)
func _update_cost(val : int):
	if _action is HubAction:
		progress_bar.max_value = _action.source_hub.max_influence
		progress_bar.value = _action.cost
	else:
		progress_bar.hide()
