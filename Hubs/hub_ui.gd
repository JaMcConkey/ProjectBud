extends Control
class_name HubUI

var hub : Hub
#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene
var hub_action_buttons : Dictionary[HubComponent,HubActionButton] #String is action_tpe

@export var influence_display_label : Label
@export var health_ui : HubHealthUI

var battle_controller : BattleController

func setup_hub_ui(p_hub : Hub):
	hub = p_hub
	battle_controller = hub.battle_controller
	hub.hub_state_changed.connect(_update_hub_ui)
	hub.hub_components_updated.connect(_update_hub_actions)
	_update_hub_actions()
func _update_hub_ui():
	influence_display_label.text = str(hub.get_current_influence())
func _update_hub_actions():
	# Get current components
	var current_components = hub.get_hub_components()
	
	# Remove buttons for components that no longer exist
	var components_to_remove = []
	for comp in hub_action_buttons:
		if not comp in current_components:
			components_to_remove.append(comp)

	for comp in components_to_remove:
		var button = hub_action_buttons[comp]
		button.queue_free()
		hub_action_buttons.erase(comp)
	
	for comp in current_components:
		if comp.get_action() and not hub_action_buttons.has(comp):
			hub_action_buttons[comp] = _add_comp_button(comp)
		if comp is HealthComponent:
			health_ui.bind_health_component(comp)
	
	
	for comp in hub_action_buttons:
		if is_instance_valid(hub_action_buttons[comp]):
			hub_action_buttons[comp].update_display()
func _add_comp_button(hub_comp : HubComponent) -> HubActionButton:
	var button = action_button_scene.instantiate() as HubActionButton
	button.set_component(hub_comp)
	button.hub_action_button_pressed.connect(_on_pressed)
	action_h_box.add_child(button)
	button.update_display() #Manually updating here, but shouldn't need to
	return button

func _on_pressed(button : HubActionButton):
	for c_button in hub_action_buttons.values():
		c_button.active = false
		if is_instance_valid(c_button):
			c_button.active = (c_button == button)
			button.hub_comp.clear_target()
			button.hub_comp.execute_action()
func show_actions():
	action_holder.show()
	for c_button in hub_action_buttons.values():
		c_button.active = false

func hide_actions():
	action_holder.hide()
