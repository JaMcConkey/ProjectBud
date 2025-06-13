extends Node
class_name ActionManager

signal target_requested(action, requester_id)  # Emitted when an action needs a target
signal target_provided(action, target, requester_id)  # Emitted when a valid target is given
signal action_completed(action)  # Emitted when execution succeeds
signal action_failed(action, reason)  # Emitted when execution fails
signal action_cancelled(action)  # Emitted when a pending action is cancelled

var pending_action: GameAction = null  # Only one action can wait for a target at a time
var pending_requester_id: String = ""  # Who requested the target?
var executing_action: GameAction = null  # Currently executing action (blocks new execution)

# Submit an action for immediate execution (fails if target is missing)
func submit_action(action: GameAction) -> bool:
	if action.requires_target and not action.has_valid_target():
		action_failed.emit(action, "No target provided")
		return false
	return _execute_action(action)

# Request a target for an action (cancels any existing request)
func request_target_for_action(action: GameAction, requester_id: String = "default") -> bool:
	if not action.requires_target:
		return false
	
	# Cancel any existing pending action
	if pending_action:
		var cancelled_action = pending_action
		cancelled_action.clear_target()
		action_cancelled.emit(cancelled_action)
	
	# Set new pending action
	pending_action = action
	pending_requester_id = requester_id
	target_requested.emit(action, requester_id)
	return true

# Provide a target to the pending action (if valid)
func provide_target(target) -> bool:
	if not pending_action:
		return false
	
	if not pending_action.is_valid_target(target):
		return false
	
	if pending_action.set_target(target):
		var action = pending_action
		var requester_id = pending_requester_id
		pending_action = null
		pending_requester_id = ""
		target_provided.emit(action, target, requester_id)
		return _execute_action(action)
	
	return false

# Cancel the current target request (if any)
func cancel_target_request() -> bool:
	if not pending_action:
		return false
	
	var action = pending_action
	action.clear_target()
	pending_action = null
	pending_requester_id = ""
	action_cancelled.emit(action)
	return true

# Execute an action (internal use only)
func _execute_action(action: GameAction) -> bool:
	executing_action = action
	
	if not action.can_execute():
		action_failed.emit(action, "Cannot execute")
		executing_action = null
		return false
	
	var success = action.execute()
	
	if success:
		if executing_action is HubAction:
			executing_action.source_hub.consume_influence(executing_action.cost)
		action_completed.emit(action)
	else:
		action_failed.emit(action, "Execution failed")
	
	executing_action = null
	return success

# Utility functions
func is_waiting_for_target() -> bool:
	return pending_action != null

func get_pending_action() -> GameAction:
	return pending_action

func is_executing() -> bool:
	return executing_action != null
