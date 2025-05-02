extends Node2D
class_name Hub

signal hub_state_changed()
signal hub_components_updated()

@export var hub_ui : HubUI

#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene


#Runtime stuff
var mouse_over : bool 
var selected : bool
var components : Array[HubComponent]

#Properties
var team_owner : Team
var _cur_influence : int :
	set(v):
		_cur_influence = v
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

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	print("MOUSE OVER")
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	print("MOUSE EXIT")
	pass # Replace with function body.

func select_node() -> Hub:
	selected = true
	$temp_highlight.show()
	hub_ui.show_actions()
	#If selected, we'll check for components that interact with it
	
	return self
func deselect_node():
	selected = false
	hub_ui.hide_actions()
	$temp_highlight.hide()

func get_current_influence() -> int:
	return _cur_influence
func apply_influence(amount, team : Team):
	if team == team_owner:
		_cur_influence += amount
		_cur_influence = mini(_cur_influence,max_influence)
	else:
		_cur_influence -= amount
		if _cur_influence < 0:
			_cur_influence = abs(_cur_influence)
			set_team(team)
func take_blob_influence(amount : int) -> bool:
	if _cur_influence < amount:
		push_error("Tried to get blob influence with not enough influence")
		return false
	_cur_influence -= amount
	return true
func get_hub_components() -> Array[HubComponent]:
	var r_array : Array[HubComponent]
	for child in get_children():
		if child is HubComponent:
			r_array.append(child)
	return r_array
func add_hub_component(hub_component : HubComponent):
	"""
	For now we want to add it WITHOUT the component having a parent
	"""
	hub_component.init_component(self)
	add_child(hub_component)
	hub_components_updated.emit()


func set_team(team : Team):
	team_owner = team
	$Sprite.modulate = team.team_color
