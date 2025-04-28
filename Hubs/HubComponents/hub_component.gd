extends Node2D
class_name HubComponent

var hub : Hub

func init_component(p_hub : Hub):
	hub = p_hub

func get_all_actions() -> Array[GameAction]:
	return []
