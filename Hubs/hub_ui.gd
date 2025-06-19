extends Control
class_name HubUI

var hub : Hub
#Action Stuff
@export var action_holder : Control
@export var action_h_box : HBoxContainer
@export var action_button_scene : PackedScene
#var hub_action_buttons : Dictionary[HubComponent,HubActionButton] #String is action_tpe
var hub_action_buttons : Array[HubActionButton]
@export var influence_display_label : Label
@export var health_ui : HubHealthUI

var _active_component : HubComponent
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

#func _update_hub_actions():
	## Get current components
	#var current_components = hub.get_hub_components()
	#
	## Remove buttons for components that no longer exist
	#var components_to_remove = []
	#for comp in hub_action_buttons:
		#if not comp in current_components:
			#components_to_remove.append(comp)
	#for comp in components_to_remove:
		#hub_action_buttons.erase(comp)
		#comp.queue_free()
	#for comp in current_components:
		#if hub_action_buttons.has(comp):
			#continue
		#else:
			#if comp.get_action() != null:
				#hub_action_buttons.append(_add_comp_button(comp))
			##Manually binding health comp if needed
			#if comp is HealthComponent:
				#health_ui.bind_health_component(comp)
	#for button in hub_action_buttons:
		#button.update_display()
#
func _add_comp_button(hub_comp : HubComponent) -> HubActionButton:
	var button = action_button_scene.instantiate() as HubActionButton
	button.set_component(hub_comp)
	#button.hub_action_button_toggled.connect(_on_toggled)
	button.hub_action_button_pressed.connect(_on_hub_action_pressed)
	action_h_box.add_child(button)
	button.update_display() #Manually updating here, but shouldn't need to
	return button
#
func _on_hub_action_pressed(button : HubActionButton):
	#make sure no others are active
	for abutton in hub_action_buttons:
		abutton.active = false
	_active_component = button.hub_comp
	button.active = true
	pass
func _on_toggled(button : HubActionButton, state : bool):
	"""
	Currently just sets the active component
	"""
	if state:
		_active_component = button.hub_comp
	for h_button in hub_action_buttons:
		if h_button == button:
			continue
		h_button.button_pressed = false
func show_actions():
	_active_component = null
	for c_button in hub_action_buttons:
		c_button.active = false
	action_holder.show()

func hide_actions():
	_active_component = null
	action_holder.hide()
func get_active_component() -> HubComponent:
	return _active_component
