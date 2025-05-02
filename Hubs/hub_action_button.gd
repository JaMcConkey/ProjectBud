extends Button
class_name HubActionButton

signal hub_action_button_pressed(button : HubActionButton)


var hub_comp : HubComponent
var active : bool :
	set(v):
		if v:
			$active.show()
		else:
			$active.hide()
		active = v

func set_component(p_hub_comp : HubComponent):
	hub_comp = p_hub_comp
	pressed.connect(_on_pressed)
	hub_comp.hub_action_updated.connect(update_display)
	update_display()

func update_display():
	if not hub_comp.get_action().can_start():
		disabled = true
	else:
		disabled = false


func _on_pressed():
	hub_action_button_pressed.emit(self)
