extends Control
class_name HubUI

var hub : Hub
#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene
var hub_action_buttons : Array[HubActionButton]
@export var influence_display_label : Label
@export var health_ui : HubHealthUI

var battle_controller : BattleController

func setup_hub_ui(p_hub : Hub):
	hub = p_hub
	battle_controller = hub.battle_controller
	hub.hub_state_changed.connect(_update_hub_ui)
	hub.hub_components_updated.connect(_update_hub_actions)
	hub.active_component_changed.connect(_on_active_component_changed)
	_update_hub_actions()

func _update_hub_ui():
	influence_display_label.text = str(hub.get_current_influence())

func _update_hub_actions():
	var current_components = hub.get_hub_components()
	
	# Remove buttons for components that no longer exist
	var buttons_to_remove: Array[HubActionButton] = []
	for button in hub_action_buttons:
		if not current_components.has(button.hub_comp):
			buttons_to_remove.append(button)
	
	for button in buttons_to_remove:
		hub_action_buttons.erase(button)
		button.queue_free()
	
	# Add buttons for new components
	for comp in current_components:
		var has_button := false
		for button in hub_action_buttons:
			if button.hub_comp == comp:
				has_button = true
				break
		
		if not has_button and comp.get_action() != null:
			var new_button = _add_comp_button(comp)
			hub_action_buttons.append(new_button)
			
			# Special case: bind health component
			if comp is HealthComponent:
				health_ui.bind_health_component(comp)
	
	# Update display for all current buttons
	for button in hub_action_buttons:
		button.update_display()
	
	# Update button states to reflect current active component
	_update_button_states()

func _add_comp_button(hub_comp : HubComponent) -> HubActionButton:
	var button = action_button_scene.instantiate() as HubActionButton
	button.set_component(hub_comp)
	button.hub_action_button_pressed.connect(_on_hub_action_pressed)
	action_h_box.add_child(button)
	button.update_display()
	return button

func _on_hub_action_pressed(button : HubActionButton):
	"""Handle button press - set active component on the hub"""
	hub.set_active_component(button.hub_comp)

func _on_active_component_changed(component: HubComponent):
	"""Called when the hub's active component changes - update UI to reflect this"""
	_update_button_states()

func _update_button_states():
	"""Update all button states to reflect the current active component"""
	for button in hub_action_buttons:
		button.active = (button.hub_comp == hub.get_active_component())

func show_actions():
	action_holder.show()

func hide_actions():
	action_holder.hide()
