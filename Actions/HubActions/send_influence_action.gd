extends HubAction
class_name SendInfluenceAction

var influence_amount: int 

var percent_send : bool
var send_percent : float :
	set(v):
		clampf(v,0,1)
		send_percent = v

func _init(source: Hub, amount: int):
	super("Send Influence", null, "influence", source, true, amount)
	influence_amount = amount
	cost = influence_amount
	requires_target = true

func execute() -> bool:
	if not super.execute():
		print("Send INF action failed to execute")
		return false
	if percent_send:
		cost = source_hub.get_current_influence() * send_percent
		influence_amount = cost
	var inf_man = source_hub.battle_controller.influence_Manager
	inf_man.send_influence(source_hub,target_hub,influence_amount)
	return true
