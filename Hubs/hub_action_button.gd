extends Button
class_name HubActionButton

signal hub_action_button_pressed(button : HubActionButton)

var _hub_action : HubAction
var _hub_comp : HubComponent
var active : bool :
	set(v):
		if v:
			$active.show()
		else:
			$active.hide()
		active = v


func set_action(p_hub_action : HubAction, p_hub_comp : HubComponent):
	#Will set icon later, placehold for now
	_hub_action = p_hub_action
	_hub_comp = p_hub_comp
	pressed.connect(_on_pressed)
func get_action() -> HubAction:
	return _hub_comp.create_action(_hub_action.action_type)
func _on_pressed():
	hub_action_button_pressed.emit(self)
