extends Node2D
class_name HubComponent

signal on_any_hub_component_updated()
signal hub_action_updated()
var hub : Hub

func init_component(p_hub : Hub):
	hub = p_hub

func get_action() -> GameAction:
	"""
	Will return null if no action
	"""
	return null

func get_all_actions() -> Array[GameAction]:
	return []
