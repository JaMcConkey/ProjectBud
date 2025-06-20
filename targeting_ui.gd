extends Control
class_name TargetingUI

var _cached_action : GameAction
var _cached_hub : Hub
var _cached_component : HubComponent
@export var st_label : Label
@export var cost_label : Label

func show_targeting_ui(action):
	st_label.show()
	cost_label.show()
	_cache_stuff(action)
func hide_targeting_ui():
	st_label.hide()
	cost_label.hide()
	_clear_cache()

func _cache_stuff(action : GameAction):
	_cached_action = action
	if action is HubAction:
		_cached_hub = action.source_hub
		_cached_component = _cached_hub.get_active_component()
func _clear_cache():
	_cached_action = null
	_cached_component = null
	_cached_hub = null

func _process(delta: float) -> void:
	#NOTE Move later to events or something, for now if its HUB based, we'll show
	#pending since that should reflect action cost
	if _cached_component:
		cost_label.text = str(_cached_component.get_pending_cost())
	elif _cached_action:
		cost_label.text = str(_cached_action.get_cost())
