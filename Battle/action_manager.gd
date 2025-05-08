extends Node
class_name ActionManager

var current_action: GameAction = null
var pending_actions: Array[GameAction] = []
var global_resources: Dictionary = {}  

signal target_selection_started(action)
signal action_completed(action)
signal action_failed(action)

func start_action(action: GameAction, pre_selected_target : Variant = null) -> void:
	print("[ActionManager] Starting action: ", action.get_class())
	current_action = action
	if not action.requires_target:
		execute_current_action()
	else:
		if action.is_valid_target(pre_selected_target):
			if pre_selected_target is Hub:
				action.target_hub = pre_selected_target
			elif pre_selected_target is Vector2:
				action.target_position = pre_selected_target
			execute_current_action()
		else:
			target_selection_started.emit(action)

func cancel_current_action() -> void:
	if current_action != null:
		print("[ActionManager] Cancelling action: ", current_action.get_class())
		action_failed.emit(current_action)
		current_action = null
	else:
		print("[ActionManager] No current action to cancel")

func select_hub_target(target_hub: Hub) -> void:
	if current_action == null or not current_action.requires_target:
		print("[ActionManager] Cannot select hub target: No current action or action doesn't require target")
		return
		
	if current_action is HubAction:
		print("[ActionManager] Hub target selected: ", target_hub.name)
		current_action.target_hub = target_hub
		execute_current_action()
	else:
		print("[ActionManager] Current action is not a HubAction, cannot select hub target")

func select_position_target(position: Vector2) -> void:
	if current_action == null or not current_action.requires_target:
		print("[ActionManager] Cannot select position target: No current action or action doesn't require target")
		return
		
	print("[ActionManager] Position target selected: ", position)
	current_action.target_position = position
	execute_current_action()

func execute_current_action() -> void:
	if current_action == null:
		print("[ActionManager] Cannot execute: No current action")
		return
		
	print("[ActionManager] Executing action: ", current_action.get_class())
	if current_action.can_execute():
		print("[ActionManager] Action can execute, attempting...")
		var success = current_action.execute()
		if success:
			print("[ActionManager] Action executed successfully")
			action_completed.emit(current_action)
		else:
			print("[ActionManager] Action execution failed")
			action_failed.emit(current_action)
	else:
		print("[ActionManager] Action cannot execute, conditions not met")
		action_failed.emit(current_action)
	
	current_action = null

func queue_action(action: GameAction) -> void:
	print("[ActionManager] Queueing action: ", action.get_class())
	pending_actions.append(action)

func process_pending_actions() -> void:
	print("[ActionManager] Processing pending actions: ", pending_actions.size(), " actions in queue")
	var completed_actions = []
	
	for action in pending_actions:
		print("[ActionManager] Checking pending action: ", action.get_class())
		if action.can_execute():
			print("[ActionManager] Executing pending action")
			var success = action.execute()
			if success:
				print("[ActionManager] Pending action executed successfully")
				completed_actions.append(action)
			else:
				print("[ActionManager] Pending action execution failed")
	
	if completed_actions.size() > 0:
		print("[ActionManager] Completed ", completed_actions.size(), " pending actions")
		for action in completed_actions:
			pending_actions.erase(action)

#AI MADE SECTION
# Manage global resources that actions might need
func set_global_resource(resource_name: String, amount: int) -> void:
	print("[ActionManager] Setting global resource '", resource_name, "' to ", amount)
	global_resources[resource_name] = amount

func get_global_resource(resource_name: String) -> int:
	var amount = 0
	if resource_name in global_resources:
		amount = global_resources[resource_name]
	print("[ActionManager] Getting global resource '", resource_name, "': ", amount)
	return amount

func consume_global_resource(resource_name: String, amount: int) -> bool:
	print("[ActionManager] Attempting to consume ", amount, " of resource '", resource_name, "'")
	if get_global_resource(resource_name) >= amount:
		global_resources[resource_name] -= amount
		print("[ActionManager] Resource consumed successfully, remaining: ", global_resources[resource_name])
		return true
	
	print("[ActionManager] Not enough resources to consume")
	return false
