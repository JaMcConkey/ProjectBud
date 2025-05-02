extends Node2D
class_name HubComponent

signal on_any_hub_component_updated()

var hub : Hub

func init_component(p_hub : Hub):
	hub = p_hub

func get_all_actions() -> Array[GameAction]:
	return []

func create_action(action_type : String) -> HubAction:
	push_error("Can't call on base class - should be implemented by subclass")
	return null
