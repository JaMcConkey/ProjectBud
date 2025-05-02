# Base Action Class
extends Resource
class_name GameAction

var name: String
var icon: Texture2D
var action_type: String  #Maybe swap to enum? Not sure
var cost: int = 0 #Generic cost, sub classes will decide what it's for
var requires_target: bool = false
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
	# Base check - subclasses will extend this
	return true

func execute() -> bool:
	if not can_execute():
		return false
	return true
