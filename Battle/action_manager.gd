extends Node
class_name ActionManager

var current_action: GameAction = null
var pending_actions: Array[GameAction] = []
var global_resources: Dictionary = {}  

signal target_selection_started(action)
signal action_completed(action)
signal action_failed(action)

func start_action(action: GameAction) -> void:
	current_action = action
	if not action.requires_target:
		execute_current_action()
	else:
		target_selection_started.emit(action)
func cancel_current_action() -> void:
	if current_action != null:
		action_failed.emit(current_action)
		current_action = null
func select_hub_target(target_hub: Hub) -> void:
	if current_action == null or not current_action.requires_target:
		return
		
	if current_action is HubAction:
		current_action.target_hub = target_hub
		execute_current_action()

func select_position_target(position: Vector2) -> void:
	if current_action == null or not current_action.requires_target:
		return
		
	current_action.target_position = position
	execute_current_action()

func execute_current_action() -> void:
	if current_action and current_action.can_execute():
		var success = current_action.execute()
		if success:
			action_completed.emit(current_action)
		else:
			action_failed.emit(current_action)
	else:
		action_failed.emit(current_action)
	
	current_action = null

func queue_action(action: GameAction) -> void:
	pending_actions.append(action)

func process_pending_actions() -> void:
	var completed_actions = []
	
	for action in pending_actions:
		if action.can_execute():
			var success = action.execute()
			if success:
				completed_actions.append(action)
	for action in completed_actions:
		pending_actions.erase(action)



#AI MADE SECTION
# Manage global resources that actions might need
func set_global_resource(resource_name: String, amount: int) -> void:
	global_resources[resource_name] = amount

func get_global_resource(resource_name: String) -> int:
	if resource_name in global_resources:
		return global_resources[resource_name]
	return 0

func consume_global_resource(resource_name: String, amount: int) -> bool:
	if get_global_resource(resource_name) >= amount:
		global_resources[resource_name] -= amount
		return true
	return false
