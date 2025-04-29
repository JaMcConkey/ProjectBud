extends Node2D
class_name Hub

#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene


var mouse_over : bool 
var selected : bool
var team_owner : Team
var _cur_influence : int :
	set(v):
		_cur_influence = v
		$Control/Label.text = str(v)
var max_influence : int = 60

var components : Array[HubComponent]
var battle_controller : BattleController


func _ready() -> void:
	add_to_group("hubs")
	for child in get_children():
		if child is HubComponent:
			add_hub_component(child)

func init_hub(p_battle_controller : BattleController):
	battle_controller = p_battle_controller

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
	show_actions()
	#If selected, we'll check for components that interact with it
	
	return self
func deselect_node():
	selected = false
	hide_actions()
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

func set_team(team : Team):
	team_owner = team
	$Sprite.modulate = team.team_color

func get_hub_actions() -> Array[HubAction]:
	#Filtering to only hub actions for now. Maybe change this?
	var r_arr : Array[HubAction]
	for hub_comp in get_hub_components():
		for action in hub_comp.get_all_actions():
			if action is HubAction:
				r_arr.append(action)
	return r_arr

func show_actions():
	action_holder.show()
	_update_action_buttons()
func hide_actions():
	action_holder.hide()


func _update_action_buttons():
	for child in action_h_box.get_children():
		child.queue_free()
	for action in get_hub_actions():
		var action_button = action_button_scene.instantiate()
		if action_button is HubActionButton:
			action_button.set_action(action)
			action_button.hub_action_button_pressed.connect(action_button_pressed)
			#action_button.pressed.connect(func(): battle_controller.action_manager.start_action(action))
			action_h_box.add_child(action_button)
			if battle_controller.action_manager.current_action == action:
				action_button.active = true

func action_button_pressed(button : HubActionButton):
	battle_controller.action_manager.start_action(button.hub_action)
	if battle_controller.action_manager.current_action == button.hub_action:
		button.active = true
