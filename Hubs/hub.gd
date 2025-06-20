# Hub.gd
extends Node2D
class_name Hub

signal hub_state_changed()
signal hub_components_updated()
signal active_component_changed(component: HubComponent)

@export var hub_ui : HubUI
@export var targetable_sprite : Sprite2D
#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene

#Runtime stuff
var mouse_over : bool 
var selected : bool
var components : Array[HubComponent]
var active_component : HubComponent :
	set(value):
		if active_component != value:
			active_component = value
			active_component_changed.emit(active_component)

var player_owned : bool :
	get:
		return team_owner == battle_controller.game_context.player_team

#Properties
var team_owner : Team
var cur_influence : int :
	set(v):
		cur_influence = v
		hub_state_changed.emit()
var max_influence : int = 60
var battle_controller : BattleController

func init_hub(p_battle_controller : BattleController):
	battle_controller = p_battle_controller
	hub_ui.setup_hub_ui(self)
	add_to_group("hubs")
	for child in get_children():
		if child is HubComponent:
			add_hub_component(child)

func set_active_component(component: HubComponent):
	"""Set the active component - can be called from UI or other systems"""
	active_component = component

func clear_active_component():
	"""Clear the active component"""
	active_component = null

func get_active_component() -> HubComponent:
	return active_component

func on_area_2d_mouse_entered() -> void:
	mouse_over = true
	print("MOUSE OVER")

func on_area_2d_mouse_exited() -> void:
	mouse_over = false
	print("MOUSE EXIT")

func select_node() -> Hub:
	selected = true
	$temp_highlight.show()
	hub_ui.show_actions()
	return self

func deselect_node():
	selected = false
	clear_active_component()  # Clear active component when deselecting
	hub_ui.hide_actions()
	$temp_highlight.hide()

func get_current_influence() -> int:
	return cur_influence

func apply_influence(amount, team : Team):
	if team == team_owner:
		cur_influence += amount
		cur_influence = mini(cur_influence, max_influence)
	else:
		cur_influence -= amount
		if cur_influence < 0:
			cur_influence = abs(cur_influence)
			set_team(team)

func consume_influence(amount : int) -> bool:
	if cur_influence < amount:
		push_error("Tried to consume influence with not enough influence")
		return false
	cur_influence -= amount
	return true

func get_hub_components() -> Array[HubComponent]:
	var r_array : Array[HubComponent]
	for child in get_children():
		if child is HubComponent:
			r_array.append(child)
	return r_array

func add_hub_component(hub_component : HubComponent):
	"""For now we want to add it WITHOUT the component having a parent"""
	hub_component.init_component(self)
	add_child(hub_component)
	hub_components_updated.emit()

func set_team(team : Team):
	team_owner = team
	$Sprite.modulate = team.team_color

func toggle_targetable_icon(state : bool):
	if state:
		targetable_sprite.show()
	else:
		targetable_sprite.hide()


func _on_hub_collider_mouse_entered() -> void:
	mouse_over = true
	print("MOUSE OVER")

func _on_hub_collider_mouse_exited() -> void:
	mouse_over = false
	print("MOUSE EXIT")
