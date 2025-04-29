extends Button
class_name HubActionButton

signal hub_action_button_pressed(button : HubActionButton)

var hub_action : HubAction
var active : bool :
	set(v):
		if v:
			$active.show()
		else:
			$active.hide()
		active = v


func set_action(p_hub_action : HubAction):
	#Will set icon later, placehold for now
	pressed.connect(_on_pressed)
	hub_action = p_hub_action
func _on_pressed():
	hub_action_button_pressed.emit(self)
