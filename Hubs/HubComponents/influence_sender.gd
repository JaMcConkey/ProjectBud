extends HubComponent
class_name InfluenceSender

var _send_val : int

func set_send_value(amount : int):
	amount = clampi(amount,0,hub.get_current_influence())
	_send_val = amount
	if _cached_action:
		_cached_action.set_send_amount(amount)
	hub_action_updated.emit()
func get_send_value() -> int:
	_send_val = clampi(_send_val,0,hub.get_current_influence())
	return _send_val

func get_action() -> GameAction:
	if _cached_action == null:
		_cached_action = SendInfluenceAction.new(hub,0)
	return _cached_action
