extends HubComponent
class_name InfluenceSender

var _send_value: int = 0
var _max_send_cache: int = 0

func init_component(p_hub: Hub) -> void:
	super.init_component(p_hub)
	_update_max_send_value()  # Initialize with current influence

func set_send_value(amount: int) -> void:
	"""Set the amount of influence to send, clamped to available amount."""
	_update_max_send_value()
	_send_value = clampi(amount, 0, _max_send_cache)
	
	if _current_action:
		_current_action.set_send_amount(_send_value)
	
	action_updated.emit()

func get_send_value() -> int:
	"""Returns the current send value, ensuring it doesn't exceed available influence."""
	_update_max_send_value()
	_send_value = clampi(_send_value, 0, _max_send_cache)
	return _send_value

func get_action() -> GameAction:
	"""Returns a configured SendInfluenceAction, creating if necessary."""
	if not _current_action:
		_current_action = SendInfluenceAction.new(hub, get_send_value())
	return _current_action

func _update_max_send_value() -> void:
	"""Update the cached maximum sendable value."""
	if hub:
		_max_send_cache = hub.get_current_influence()
		# Auto-correct if current value exceeds new max
		if _send_value > _max_send_cache:
			set_send_value(_max_send_cache)

# Optional: Override execution for additional influence checks
func execute_action(ignore_cooldown: bool = false) -> bool:
	if get_send_value() <= 0:
		push_warning("Attempted to send 0 influence")
		return false
	return super.execute_action(ignore_cooldown)
