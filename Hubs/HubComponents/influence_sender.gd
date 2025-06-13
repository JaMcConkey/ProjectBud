extends HubComponent
class_name InfluenceSender
var _send_value: int = 0
var pending_send_val = 0 :
	set(v):
		clampi(v,0,hub.max_influence)
		pending_send_val = v
func init_component(p_hub: Hub) -> void:
	super.init_component(p_hub)
	#_update_max_send_value()  # Initialize with current influence

func set_send_value(amount: int) -> void:
	"""Set the amount of influence to send, clamped to available amount."""
	#_update_max_send_value()
	#_send_value = clampi(amount, 0, hub.get_current_influence())
	_send_value = amount
	if _current_action:
		_current_action.set_send_amount(_send_value)
	action_updated.emit()

func start_targeting() -> void:
	#var act = get_action() as SendInfluenceAction
	#pending_send_val = act.get_influence_blob_size()
	super()

func get_send_value() -> int:
	"""Returns the current send value, ensuring it doesn't exceed available influence."""
	#_update_max_send_value()
	_send_value = clampi(_send_value, 0, hub.get_current_influence())
	return _send_value

func get_action() -> GameAction:
	"""Returns a configured SendInfluenceAction, creating if necessary."""
	if not _current_action:
		_current_action = SendInfluenceAction.new(hub, 1)
		action_updated.emit()
		component_updated.emit()
	return _current_action
func _update_action() -> bool:
	set_send_value(pending_send_val)
	return super()
#func _update_max_send_value() -> void:
	#"""Update the cached maximum sendable value."""
	#if hub:
		#_max_send_cache = hub.get_current_influence()
		## Auto-correct if current value exceeds new max
		#if _send_value > _max_send_cache:
			#set_send_value(_max_send_cache)

# Optional: Override execution for additional influence checks
func execute_action(ignore_cooldown: bool = false) -> bool:
	if get_action().get_influence_blob_size() <= 0:
		return false
	return super.execute_action(ignore_cooldown)
func increase(step = 1):
	"""
	Attemps to increase the pending send value(And Cost) by the step size
	"""
	pending_send_val += step

func decrease(step = 1):
	"""
	Attemps to increase the pending send value(And Cost) by the step size
	"""
	var new_val = pending_send_val - step
	pending_send_val = clampi(new_val,0,hub.max_influence)
func ui_set_active(val : bool):
	"""
	Called by the ui to inform if active
	"""
	if val:
		pending_send_val = get_action().get_influence_blob_size()
	pass
