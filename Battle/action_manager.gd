extends Node
class_name ActionManager

signal target_required(action, requester_id)
signal target_provided(action, target, requester_id)
signal action_completed(action)
signal action_failed(action, reason)
signal action_cancelled(action)

var current_action: GameAction = null
var current_requester_id: String = ""

func submit_action(action: GameAction) -> bool:
	if current_action:
		cancel_current_action()
	
	current_action = action
	
	if action.requires_target:
		target_required.emit(action, "direct")
		return true
	else:
		return _execute_action(action)

# NEW: For hub components to request targets
func request_target_for_action(action: GameAction, requester_id: String) -> bool:
	if not action.requires_target:
		return false
	
	# Handle existing action
	if current_action:
		cancel_current_action()
	
	current_action = action
	current_requester_id = requester_id
	target_required.emit(action, requester_id)
	return true

func provide_target(target) -> bool:
	if not current_action:
		return false
	
	if current_action.set_target(target):
		target_provided.emit(current_action, target, current_requester_id)
		return _execute_action(current_action)
	return false

func cancel_current_action():
	if current_action:
		current_action.clear_target()
		action_cancelled.emit(current_action)
		current_action = null
		current_requester_id = ""

func _execute_action(action: GameAction) -> bool:
	if not action.can_execute():
		action_failed.emit(action, "Cannot execute")
		_clear_current()
		return false
	
	var success = action.execute()
	
	if success:
		action_completed.emit(action)
	else:
		action_failed.emit(action, "Execution failed")
	
	_clear_current()
	return success

func _clear_current():
	current_action = null
	current_requester_id = ""
