extends HubAction
class_name SendInfluenceAction

const icon_preload = preload("res://Art/Icons/send_inf.png")

var influence_amount: int 
var _inf_man : InfluenceManager

func _init(source: Hub, amount: int):	
	super("Send Influence", icon_preload, "send_influence",source.team_owner, source, true, amount)
	set_send_amount(amount)
	requires_target = true
	_inf_man = source.battle_controller.influence_Manager

func set_send_amount(val : int):
	"""
	By Default, COST and SEND amount will be equal
	"""
	influence_amount = val
	cost = val

func execute() -> bool:
	if not super.execute():
		print("Send INF action failed to execute")
		return false
	_inf_man.send_influence(source_hub,target_hub,influence_amount)
	return true

func is_valid_target(target) -> bool:
	if target is Hub:
		if _inf_man.can_receive_influence(target):
			return true
	return false
