# Base Action Class
extends Resource
class_name GameAction

signal target_updated(target)
signal cost_updated(new_cost : int)

enum TARGET_TYPE{
	NONE,
	POSITION,
	HUB
}

var action_name: String
var icon: Texture2D
var source_team : Team
var cost: int = 0 #Generic cost, sub classes will decide what it's for
var requires_target: bool = false
var target_type : TARGET_TYPE
var target_hub: Hub = null  # Optional, for hub-to-hub actions

var target_position: Vector2 = Vector2.ZERO  

var _max_cost : int

func _init(p_team : Team):
	source_team = p_team
	_setup_action()
func _setup_action():
	"""Initlaize values like icon, etc"""
	push_error("This should be overriden by child class")
func set_cost(new_value):
	cost = new_value
	cost_updated.emit(cost)

func get_max_cost() -> int:
	return _max_cost
func get_cost() -> int:
	"""
	Returns the cost (Influence for HubActions normally)
	"""
	return cost
func can_execute() -> bool:
	"""
	Checks if action meets ALL requirements to execute
	(Including a target if needed)
	"""
	## Base check - subclasses will extend this
	return true

func execute() -> bool:
	if not can_execute():
		return false
	return true
func has_valid_target() -> bool:
	if requires_target:
		match target_type:
			TARGET_TYPE.NONE:
				return true
			TARGET_TYPE.POSITION:
				if target_position != Vector2.ZERO:
					return true
			TARGET_TYPE.HUB:
				if target_hub != null:
					return true
	return false
func is_valid_target(target) -> bool:
	"""
	By default, parent class just checks for TYPE
	"""
	if requires_target:
		match target_type:
			TARGET_TYPE.NONE:
				return true
			TARGET_TYPE.POSITION:
				if target is Vector2:
					return true
			TARGET_TYPE.HUB:
				if target is Hub:
					return true
	return false
func set_target(target) -> bool:
	if is_valid_target(target):
		if target is Vector2:
			target_position = target
		elif target is Hub:
			target_hub = target
		else:
			push_error("?????? Invalid target type?")
		return true
	return false
func clear_target():
	target_hub = null
	target_position = Vector2.ZERO
