extends HubComponent
class_name InfluenceSender

var send_val : int
var _cached_action : SendInfluenceAction

func set_send_value(amount : int):
	if _cached_action:
		_cached_action.cost = amount
	on_any_hub_component_updated.emit()
	pass

func get_all_actions() -> Array[GameAction]:
	if _cached_action == null:
		_cached_action = SendInfluenceAction.new(hub,send_val)
		_cached_action.percent_send = true
		_cached_action.send_percent = .5
	var r_arr : Array[GameAction]
	r_arr.append(_cached_action)
	return r_arr
