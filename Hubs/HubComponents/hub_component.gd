extends Node2D
class_name HubComponent

signal component_updated()  # More generic signal name
signal action_updated()     # Specific to action changes

@export var action_cooldown: float = 3.0
var hub: Hub = null
var _current_target: Variant = null
var _current_action: GameAction = null
var _cooldown_timer: float = 0.0
var _auto_execute_timer: float = 0.0
var _auto_execute_enabled: bool = false
var _action_in_progress: bool = false
var _action_manager : ActionManager
var _tar_line : Line2D
func init_component(p_hub: Hub) -> void:
	"""Initialize the component with its parent Hub."""
	hub = p_hub
	_action_manager = hub.battle_controller.action_manager
	_auto_execute_enabled = true
	_cache_action()  # Cache action on init
	_tar_line = Line2D.new()
	add_child(_tar_line)
	_tar_line.show_behind_parent = true
	_action_manager.action_completed.connect(_on_action_completed)

func toggle_auto_fire(val : bool):
	_auto_execute_enabled = val

func get_action() -> GameAction:
	"""Returns the current action, or null if none exists."""
	return _current_action

func get_all_actions() -> Array[GameAction]:
	"""Returns all potential actions this component can produce."""
	return []

func execute_action(ignore_cooldown: bool = false) -> bool:
	"""Attempt to execute the current action. Returns success status."""
	if not _current_action:
		push_error("Attempted to execute null action")
		return false
		
	if _cooldown_timer > 0 and not ignore_cooldown:
		return false
		
	if !_current_action.can_start():
		return false
		
	_action_in_progress = true
	if _action_manager.submit_action(_current_action):
		return true
	#If submit fails, no longer in progress
	_action_in_progress = false
	return false

func start_targeting() -> void:
	"""Calls action manager to start setting a target"""
	if get_action() == null:
		return
	if _action_manager.request_target_for_action(get_action(),str(get_instance_id())):
		if _action_manager.target_provided.is_connected(_on_action_manager_provide_target):
			_action_manager.target_provided.connect(_on_action_manager_provide_target)
	pass

func _on_action_manager_provide_target(action : GameAction, target : Variant, id : String):
	if id != str(get_instance_id()):
		return
	set_target(action,target)

func set_target(action : GameAction, new_target : Variant) -> void:
	"""Set a new target for the action if valid."""
	if not _current_action or action != _current_action:
		return
		
	if _current_action.is_valid_target(new_target):
		_current_target = new_target
		action_updated.emit()
	_update_target_line()
	#Try to execut after setting target
	execute_action()

func clear_target() -> void:
	"""Clears current target for Hub Comp AND action"""
	_current_target = null
	get_action().clear_target()
	_update_target_line()
func _process(delta: float) -> void:
	"""Handle cooldowns and auto-execution."""
	_update_cooldowns(delta)
	if _auto_execute_enabled and not _action_in_progress:
		_try_auto_execute(delta)

#region Internal Functions -----------------------------------------------------
func _update_target_line():
	"""Updates the action target line - Children should set their own textures"""
	if _current_target != null:
		_tar_line.points = [Vector2.ZERO,to_local(_current_target.global_position)]
	else:
		_tar_line.clear_points()
func _cache_action() -> void:
	"""Cache the current action and validate any existing target."""
	_current_action = get_action()
	if _current_action and _current_target:
		if not _current_action.is_valid_target(_current_target):
			_current_target = null
	action_updated.emit()
	component_updated.emit()

func _update_cooldowns(delta: float) -> void:
	"""Update all cooldown timers."""
	if _cooldown_timer > 0:
		_cooldown_timer = max(0.0, _cooldown_timer - delta)
		
	if _auto_execute_timer > 0:
		_auto_execute_timer = max(0.0, _auto_execute_timer - delta)

func _try_auto_execute(delta: float) -> void:
	"""Attempt automatic execution if conditions are met."""
	if not _current_action or _auto_execute_timer > 0:
		return

	if !_current_action.has_valid_target():
		return
		
	if execute_action():
		_auto_execute_timer = action_cooldown

func _on_action_completed(action: GameAction) -> void:
	"""Handle action completion cleanup."""
	if action == _current_action:
		_cooldown_timer = action_cooldown
		_action_in_progress = false
		component_updated.emit()
		

#endregion
