extends HubComponent
class_name InfluenceSender

var _send_val : int 
var _cached_action : SendInfluenceAction

func set_send_value(amount : int):
	amount = clampi(amount,0,hub.get_current_influence())
	_send_val = amount
	if _cached_action:
		_cached_action.set_send_amount(amount)
	on_any_hub_component_updated.emit()
func get_send_value() -> int:
	_send_val = clampi(_send_val,0,hub.get_current_influence())
	return _send_val

func get_all_actions() -> Array[GameAction]:
	if _cached_action == null:
		_cached_action = SendInfluenceAction.new(hub,_send_val)
	else:
		_cached_action.set_send_amount(_send_val)
	var r_arr : Array[GameAction]
	r_arr.append(_cached_action)
	return r_arr

func create_action(type : String) -> HubAction:
	if type == "send_influence":
		var action = SendInfluenceAction.new(hub,_send_val)
		return action
	return null
