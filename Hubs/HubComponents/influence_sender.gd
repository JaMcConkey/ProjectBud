extends HubComponent
class_name InfluenceSender
var _send_value: int = 0


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

func get_pending_cost() -> int:
	return super()

func start_targeting() -> bool:
	#var act = get_action() as SendInfluenceAction
	#pending_send_val = act.get_influence_blob_size()
	return super()


func get_action() -> GameAction:
	"""Returns a configured SendInfluenceAction, creating if necessary."""
	if not _current_action:
		_current_action = SendInfluenceAction.new(hub, 1)
		action_updated.emit()
		component_updated.emit()
	return _current_action
func _update_action() -> bool:
	set_send_value(_pending_cost)
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
	_pending_cost += step
	_pending_cost = clampi(_pending_cost,1,hub.max_influence)
	component_updated.emit()


func decrease(step = 1):
	"""
	Attemps to increase the pending send value(And Cost) by the step size
	"""
	_pending_cost -= step
	_pending_cost = clampi(_pending_cost,1,hub.max_influence)
	component_updated.emit()

func ui_set_active(val : bool):
	"""
	Called by the ui to inform if active - Preset pending cost here
	"""
	if val:
		_pending_cost = get_action().get_influence_blob_size()
	pass
func _on_action_manager_provide_target(action : GameAction, target : Variant, id : String):
	super(action,target,id)
