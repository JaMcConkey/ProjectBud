# Base Action Class
extends Resource
class_name GameAction

enum TARGET_TYPE{
	NONE,
	POSITION,
	HUB
}

var name: String
var icon: Texture2D
var action_type: String  #Maybe swap to enum? Not sure
var source_team : Team
var cost: int = 0 #Generic cost, sub classes will decide what it's for
var requires_target: bool = false
var target_type : TARGET_TYPE
var target_hub: Hub = null  # Optional, for hub-to-hub actions

var target_position: Vector2 = Vector2.ZERO  

func _init(p_name: String, p_icon: Texture2D, p_type: String, p_requires_target: bool = false, p_cost: int = 0):
	name = p_name
	icon = p_icon
	action_type = p_type
	requires_target = p_requires_target
	cost = p_cost

func can_start() -> bool:
	"""Checks if an action can be started"""
	return true

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
func has_target() -> bool:
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
