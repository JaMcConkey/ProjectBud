extends Node2D
class_name Hub

# UI Elements
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene

# Visual Elements
@export var selection_highlight : Node2D
@export var drag_highlight : Node2D
@export var action_highlight : Node2D
@export var influence_label : Label

# State Variables
var mouse_over : bool = false
var selected : bool = false
var team_owner : Team
var _cur_influence : int = 0 :
	set(value):
		_cur_influence = clamp(value, 0, max_influence)
		influence_label.text = str(_cur_influence)
var max_influence : int = 60

# Component System
var components : Array[HubComponent] = []
var battle_controller : BattleController
var _highlighted_action : HubAction = null

func _ready() -> void:
	add_to_group("hubs")
	# Initialize visual elements
	selection_highlight.hide()
	drag_highlight.hide()
	action_highlight.hide()
	action_holder.hide()
	
	# Set up components
	for child in get_children():
		if child is HubComponent:
			add_hub_component(child)

func init_hub(p_battle_controller : BattleController) -> void:
	battle_controller = p_battle_controller

# Input and Interaction Functions
func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	if battle_controller._cur_mode == BattleController.STATE.DragSelection:
		battle_controller._drag_target_hub = self

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	if battle_controller._cur_mode == BattleController.STATE.DragSelection && battle_controller._drag_target_hub == self:
		battle_controller._drag_target_hub = null

# Selection and Visual Feedback Functions
func select_node() -> Hub:
	selected = true
	selection_highlight.show()
	show_actions()
	return self

func deselect_node() -> void:
	selected = false
	selection_highlight.hide()
	hide_actions()
	clear_action_highlight()

func start_drag() -> void:
	drag_highlight.show()
	# Highlight the first action by default for drag operations
	var actions = get_hub_actions()
	if actions.size() > 0:
		highlight_action(actions[0])

func end_drag() -> void:
	drag_highlight.hide()
	clear_action_highlight()

func highlight_action(action: HubAction) -> void:
	_highlighted_action = action
	action_highlight.show()
	
	# Position highlight over the corresponding button if available
	for button in action_h_box.get_children():
		if button is HubActionButton and button._hub_action == action:
			var button_rect = button.get_global_rect()
			action_highlight.global_position = button_rect.position + button_rect.size / 2
			action_highlight.scale = Vector2(button_rect.size.x / action_highlight.texture.get_width(), 
										   button_rect.size.y / action_highlight.texture.get_height())
			break

func clear_action_highlight() -> void:
	_highlighted_action = null
	action_highlight.hide()

# Action Management Functions
func show_actions() -> void:
	action_holder.show()
	_update_action_buttons()

func hide_actions() -> void:
	action_holder.hide()

func _update_action_buttons() -> void:
	# Clear existing buttons
	for child in action_h_box.get_children():
		child.queue_free()
	
	# Create new buttons for each action
	for action in get_hub_actions():
		var action_button = action_button_scene.instantiate()
		if action_button is HubActionButton:
			action_button.set_action(action)
			action_button.pressed.connect(
				func(): 
					battle_controller.action_manager.start_action(action)
					highlight_action(action)
			)
			action_h_box.add_child(action_button)

# Influence Management Functions
func get_current_influence() -> int:
	return _cur_influence

func apply_influence(amount: int, team: Team) -> void:
	if team == team_owner:
		_cur_influence += amount
	else:
		_cur_influence -= amount
		if _cur_influence < 0:
			# If influence goes negative, change ownership
			_cur_influence = abs(_cur_influence)
			set_team(team)

func take_blob_influence(amount: int) -> bool:
	if _cur_influence < amount:
		push_error("Tried to take more influence than available")
		return false
	_cur_influence -= amount
	return true

# Team Management Functions
func set_team(team: Team) -> void:
	team_owner = team
	$Sprite.modulate = team.team_color
	# Update any team-specific visuals
	selection_highlight.modulate = team.team_color.lightened(0.2)
	drag_highlight.modulate = team.team_color.lightened(0.1)

# Component Management Functions
func get_hub_components() -> Array[HubComponent]:
	return components.duplicate()

func add_hub_component(hub_component: HubComponent) -> void:
	hub_component.init_component(self)
	components.append(hub_component)
	add_child(hub_component)
	# Update actions when new component is added
	_update_action_buttons()

func remove_hub_component(hub_component: HubComponent) -> void:
	components.erase(hub_component)
	hub_component.queue_free()
	# Update actions when component is removed
	_update_action_buttons()

# Action Query Functions
func get_hub_actions() -> Array[HubAction]:
	var actions : Array[HubAction] = []
	for hub_comp in components:
		for action in hub_comp.get_all_actions():
			if action is HubAction:
				actions.append(action)
	return actions

func get_available_actions() -> Array[GameAction]:
	var available_actions : Array[GameAction] = []
	for hub_comp in components:
		for action in hub_comp.get_all_actions():
			if action.is_available():
				available_actions.append(action)
	return available_actions

# Utility Functions
func has_component(component_class: String) -> bool:
	for comp in components:
		if comp.is_class(component_class):
			return true
	return false

func get_component(component_class: String) -> HubComponent:
	for comp in components:
		if comp.is_class(component_class):
			return comp
	return null
