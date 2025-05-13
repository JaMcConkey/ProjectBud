extends Node
class_name ActionManager

# Simplified execution context
enum ExecutionContext {
	PLAYER_UI,      # From player interface
	DIRECT          # Immediate system/AI execution
}

var _current_player_action: GameAction = null
var _direct_action_queue: Array[GameAction] = []

signal player_target_selection_started(action)
signal action_completed(action)
signal action_failed(action)
signal action_rejected(action, reason)

# Main Public Interface --------------------------------------------------------

func submit_action(action: GameAction, team: Team, context: ExecutionContext = ExecutionContext.DIRECT) -> bool:
	action.source_team = team
	
	if not _validate_action(action, context):
		action_rejected.emit(action, "Invalid action for team %s" % team.team_name)
		return false
	
	match context:
		ExecutionContext.PLAYER_UI:
			return _handle_player_action(action)
		ExecutionContext.DIRECT:
			return _execute_immediate(action)
	
	return false

func cancel_current_player_action():
	if _current_player_action:
		action_failed.emit(_current_player_action)
		_current_player_action = null

func select_player_target(target: Variant):
	if not _current_player_action:
		return
		
	if target is Hub:
		_current_player_action.target_hub = target
	elif target is Vector2:
		_current_player_action.target_position = target
	
	_execute_immediate(_current_player_action)
	_current_player_action = null

func process_queues():
	var completed_actions = []
	
	for action in _direct_action_queue:
		if action.can_execute():
			if _execute_immediate(action):
				completed_actions.append(action)
	
	for action in completed_actions:
		_direct_action_queue.erase(action)

# Core Execution Flow ----------------------------------------------------------

func _handle_player_action(action: GameAction) -> bool:
	if _current_player_action:
		cancel_current_player_action()
	
	_current_player_action = action
	
	if action.requires_target:
		player_target_selection_started.emit(action)
		return true
	else:
		return _execute_immediate(action)

func _execute_immediate(action: GameAction) -> bool:
	if not action.can_execute():
		action_failed.emit(action)
		return false
	
	var success = action.execute()
	if success:
		action_completed.emit(action)
	else:
		action_failed.emit(action)
	
	return success

# Validation -------------------------------------------------------------------

func _validate_action(action: GameAction, context: ExecutionContext) -> bool:
	# Team-based validation
	if not action.source_team:
		return false
		
	if context == ExecutionContext.PLAYER_UI and not action.source_team.is_local:
		return false
		
	if action.requires_human and action.source_team.is_ai:
		return false
	
	return action.is_valid()
