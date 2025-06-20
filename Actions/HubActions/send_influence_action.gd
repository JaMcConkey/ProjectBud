extends HubAction
class_name SendInfluenceAction

const icon_preload = preload("res://Art/Icons/send_inf.png")

var influence_amount: int 
var _inf_man : InfluenceManager

func _init(source_hub : Hub, amount: int):
	super(source_hub)
	_setup_action()
	set_send_amount(amount)
	_inf_man = source_hub.battle_controller.influence_Manager
func _setup_action():
	icon = icon_preload
	action_name = "Send Influence"
	requires_target = true
	target_type = TARGET_TYPE.HUB
func set_send_amount(val : int,match_cost : bool = true):
	"""
	By Default, COST and SEND amount will be equal
	"""
	influence_amount = val
	if match_cost:
		set_cost(val)

func get_influence_blob_size() -> int:
	return influence_amount
func execute() -> bool:
	if not super.execute():
		print("Send INF action failed to execute")
		return false
	_inf_man.send_influence(source_hub,target_hub,get_influence_blob_size())
	return true

func is_valid_target(target) -> bool:
	if target is Hub:
		if target == source_hub:
			return false
		if _inf_man.can_receive_influence(target):
			return true
	return false
