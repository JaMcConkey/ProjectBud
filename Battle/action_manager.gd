extends Node
class_name ActionManager

# Simplified execution context
enum ExecutionContext {
	PLAYER_INPUT,      # From player interface
	DIRECT          # Immediate system/AI execution
}

enum ActionState {
	PENDING,           # Action submitted, waiting for requirements
	AWAITING_TARGET,   # Action needs target selection
	READY,            # Action ready to execute
	EXECUTING,        # Action currently executing
	COMPLETED,        # Action finished successfully
	FAILED            # Action failed or was cancelled
}

var current_player_action: GameAction = null
var direct_action_queue: Array[GameAction] = []

# Track action states separately from the actions themselves
var action_states: Dictionary = {}  # GameAction -> ActionState

# New signals for cleaner separation
signal action_submitted(action)
signal target_required(action)
signal target_selected(action, target)
signal player_input_received(input)
signal action_completed(action)
signal action_failed(action)
signal action_rejected(action, reason)

# Main Public Interface --------------------------------------------------------

func submit_action(action: GameAction, team: Team, context: ExecutionContext = ExecutionContext.DIRECT) -> bool:
	"""Submit an action for processing. Target selection handled separately if needed."""
	action.source_team = team
	action_states[action] = ActionState.PENDING
	
	if not validate_action(action, context):
		action_states[action] = ActionState.FAILED
		action_rejected.emit(action, "Invalid action for team %s" % team.team_name)
		return false
	
	action_submitted.emit(action)
	
	match context:
		ExecutionContext.PLAYER_INPUT:
			return handle_player_action(action)
		ExecutionContext.DIRECT:
			return process_action(action)
	
	return false

func request_target_for_action(action: GameAction) -> bool:
	"""Explicitly request target selection for an action."""
	if not action:
		return false
	
	# If action isn't being tracked yet, add it as PENDING
	if not action in action_states:
		action_states[action] = ActionState.PENDING
	
	var current_state = get_action_state(action)
	
	# Only allow target requests for actions that aren't already executing/completed
	if current_state == ActionState.EXECUTING or current_state == ActionState.COMPLETED:
		return false
	
	if not action.requires_target:
		# Action doesn't need a target, try to execute directly
		return process_action(action)
	
	action_states[action] = ActionState.AWAITING_TARGET
	current_player_action = action
	target_required.emit(action)
	return true

func provide_target(target: Variant, action: GameAction = null) -> bool:
	"""Provide a target for the current action or specified action."""
	var target_action = action if action else current_player_action
	
	if not target_action or get_action_state(target_action) != ActionState.AWAITING_TARGET:
		push_error("No action awaiting target")
		return false
	
	if not target_action.is_valid_target(target):
		push_error("Invalid target provided")
		return false
	
	if target_action.set_target(target):
		action_states[target_action] = ActionState.READY
		target_selected.emit(target_action, target)
		player_input_received.emit(target)
		
		# Execute immediately after target is set
		return execute_immediate(target_action)
	
	return false

func cancel_current_player_action():
	"""Cancel the current player action if one exists."""
	if current_player_action:
		action_states[current_player_action] = ActionState.FAILED
		action_failed.emit(current_player_action)
		_cleanup_action(current_player_action)
		current_player_action = null

func process_queues():
	"""Process all queued direct actions."""
	var completed_actions = []
	
	for action in direct_action_queue.duplicate():  # Use duplicate to avoid modification during iteration
		var state = get_action_state(action)
		
		# Skip actions that aren't ready
		if state != ActionState.READY and state != ActionState.PENDING:
			continue
			
		# Process pending actions first
		if state == ActionState.PENDING:
			if not process_action(action):
				continue
		
		# Try to execute ready actions
		if get_action_state(action) == ActionState.READY and action.can_execute():
			if execute_immediate(action):
				completed_actions.append(action)
	
	# Remove completed actions from queue
	for action in completed_actions:
		direct_action_queue.erase(action)

# Core Execution Flow ----------------------------------------------------------

func handle_player_action(action: GameAction) -> bool:
	"""Handle player-initiated actions."""
	if current_player_action:
		cancel_current_player_action()
	
	current_player_action = action
	
	# Check if action needs a target
	if action.requires_target:
		return request_target_for_action(action)
	else:
		return process_action(action)

func process_action(action: GameAction) -> bool:
	"""Process an action, handling target requirements automatically."""
	if action.requires_target and not action.has_valid_target():
		# Action needs target but doesn't have one
		action_states[action] = ActionState.AWAITING_TARGET
		return request_target_for_action(action)
	else:
		# Action is ready to execute
		action_states[action] = ActionState.READY
		return execute_immediate(action)

func execute_immediate(action: GameAction) -> bool:
	"""Execute an action immediately."""
	if not action.can_execute():
		action_states[action] = ActionState.FAILED
		action_failed.emit(action)
		_cleanup_action(action)
		return false
	
	action_states[action] = ActionState.EXECUTING
	var success = action.execute()
	
	if success:
		action_states[action] = ActionState.COMPLETED
		action_completed.emit(action)
		
		# Clear current player action if this was it
		if current_player_action == action:
			current_player_action = null
	else:
		action_states[action] = ActionState.FAILED
		action_failed.emit(action)
	
	_cleanup_action(action)
	return success

# Validation -------------------------------------------------------------------

func validate_action(action: GameAction, context: ExecutionContext) -> bool:
	"""Validate if an action can be submitted in the given context."""
	# Future multiplayer validation could go here
	return true

# State Management -------------------------------------------------------------

func get_action_state(action: GameAction) -> ActionState:
	"""Get the current state of a specific action."""
	return action_states.get(action, ActionState.FAILED)

func get_current_action_state() -> ActionState:
	"""Get the state of the current player action."""
	if current_player_action:
		return get_action_state(current_player_action)
	return ActionState.COMPLETED  # No current action

func is_awaiting_target() -> bool:
	"""Check if we're currently waiting for target selection."""
	return current_player_action != null and get_action_state(current_player_action) == ActionState.AWAITING_TARGET

func get_pending_actions() -> Array[GameAction]:
	"""Get all actions that are pending execution."""
	var pending = []
	
	for action in action_states.keys():
		var state = action_states[action]
		if state != ActionState.COMPLETED and state != ActionState.FAILED:
			pending.append(action)
	
	return pending

func get_actions_by_state(state: ActionState) -> Array[GameAction]:
	"""Get all actions currently in a specific state."""
	var actions = []
	
	for action in action_states.keys():
		if action_states[action] == state:
			actions.append(action)
	
	return actions

# Cleanup ----------------------------------------------------------------------

func _cleanup_action(action: GameAction):
	"""Clean up completed or failed actions to prevent memory leaks."""
	var state = get_action_state(action)
	if state == ActionState.COMPLETED or state == ActionState.FAILED:
		# Remove from state tracking after a brief delay to allow signal handlers to process
		call_deferred("_remove_action_state", action)

func _remove_action_state(action: GameAction):
	"""Remove action from state tracking."""
	action_states.erase(action)

func clear_all_actions():
	"""Clear all tracked actions and reset manager state."""
	action_states.clear()
	current_player_action = null
	direct_action_queue.clear()
