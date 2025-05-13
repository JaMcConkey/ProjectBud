extends Button
class_name HubActionButton

signal hub_action_button_pressed(button : HubActionButton)

@export var highlight: TextureRect
@export var action_icon: TextureRect


var hub_comp : HubComponent
var active : bool :
	set(v):
		if v:
			highlight.show()
		else:
			highlight.hide()
		active = v

func set_component(p_hub_comp : HubComponent):
	hub_comp = p_hub_comp
	pressed.connect(_on_pressed)
	hub_comp.action_updated.connect(update_display)
	update_display()

func update_display():
	var action : HubAction
	action = hub_comp.get_action()
	if action:
		action_icon.texture = hub_comp.get_action().icon
		if action.can_start():
			disabled = false
		else:
			disabled = true
	else:
		push_warning("No action assigned here, why is there a button")


func _on_pressed():
	hub_action_button_pressed.emit(self)
