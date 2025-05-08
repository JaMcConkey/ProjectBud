extends Node2D
class_name HubComponent

signal on_any_hub_component_updated()
signal hub_action_updated()
var hub : Hub
var _cached_target : Hub
var _cached_action : GameAction
var action_cooldown : float = 3
var cooldown_timer : float
var _auto_execute_timer : float
var _auto_execute : bool
func init_component(p_hub : Hub):
	hub = p_hub
	_auto_execute = true
func get_action() -> GameAction:
	"""
	Will return null if no action
	"""
	return null
func execute_hub_action(ignore_cooldown : bool = false) -> bool:
	if not get_action():
		push_warning("No Action to execute, why is this called")
		return false
	if _cached_action.can_start():
		hub.battle_controller.action_manager.start_action(_cached_action)
		hub.battle_controller.action_manager.action_completed.connect(_on_action_done)
	return true
func _on_action_done(action : GameAction):
	if action == _cached_action:
		cooldown_timer = action_cooldown
		hub.battle_controller.action_manager.action_completed.disconnect(_on_action_done)
func _auto_execute_action(delta : float) -> bool:
	if not get_action() or not _auto_execute or not _cached_action:
		return false
	if _auto_execute_timer >= 0:
		_auto_execute_timer -= delta
	else:
		if _cached_action.can_start():
			if _cached_action.requires_target and _cached_target:
				hub.battle_controller.action_manager.start_action(_cached_action,_cached_target)
				_auto_execute_timer = action_cooldown
	return false
func cache_target(p_target):
	if not _cached_action:
		return
	if _cached_action.is_valid_target(p_target):
		_cached_target = p_target
func get_all_actions() -> Array[GameAction]:
	return []
func _process(delta: float) -> void:
	_auto_execute_action(delta)
	if cooldown_timer >= 0:
		cooldown_timer -= delta
