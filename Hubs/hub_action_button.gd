extends Button
class_name HubActionButton

signal hub_action_button_toggled(button : HubActionButton, state : bool)
signal hub_action_button_pressed (button : HubActionButton)

@export var prog_bar : TextureProgressBar
@export var highlight: TextureRect
@export var action_icon: TextureRect
@export var set_target_button : Button
@export var clear_target_button : Button
@export var toggle_auto_fire : CheckButton
@export var expand_panel : Control
var hub_comp : HubComponent
var active : bool :
	set(v):
		highlight.visible = v
		active = v

func set_component(p_hub_comp : HubComponent):
	hub_comp = p_hub_comp
	#toggle_mode = true
	#toggled.connect(_on_toggle)
	toggle_auto_fire.set_pressed_no_signal(hub_comp._auto_execute_enabled)
	_connect_signals()
	update_display()
func _connect_signals():
	pressed.connect(_on_pressed)
	hub_comp.action_updated.connect(update_display)
	toggle_auto_fire.toggled.connect(on_auto_fire_toggled)
	set_target_button.pressed.connect(_on_set_target_pressed)
	clear_target_button.pressed.connect(_on_clear_target_pressed)

func update_display():
	var action : HubAction
	action = hub_comp.get_action()
	if action:
		prog_bar.texture_under = action.icon
		prog_bar.texture_progress = action.icon
		if action.has_valid_target():
			clear_target_button.show()
		else:
			clear_target_button.hide()
	else:
		push_warning("No action assigned here, why is there a button")
func _on_set_target_pressed():
	hub_comp.start_targeting()
	update_display()
func _on_clear_target_pressed():
	hub_comp.clear_target()
	update_display()
	
func on_auto_fire_toggled(val : bool):
	hub_comp.toggle_auto_fire(val)
	pass

func _on_pressed():
	hub_action_button_pressed.emit(self)
	hub_comp.start_targeting()

func _on_toggle(toggled_on : bool):
	if toggled_on:
		hub_action_button_toggled.emit(self,toggled_on)
	expand_panel.visible = toggled_on
	highlight.visible = toggled_on
func _process(delta: float) -> void:
	if hub_comp.get_action():
		prog_bar.max_value = hub_comp.action_cooldown
		prog_bar.value = hub_comp.action_cooldown - hub_comp.get_cd_time_remaining()
