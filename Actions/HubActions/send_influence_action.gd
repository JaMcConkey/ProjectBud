extends HubAction
class_name SendInfluenceAction

var influence_amount: int

func _init(source: Hub, amount: int):
	super("Send Influence", null, "influence", source, true, amount)
	influence_amount = amount
	requires_target = true

func execute() -> bool:
	if not super.execute():
		return false
	var inf_man = source_hub.battle_controller.influence_Manager
	inf_man.send_influence(source_hub,target_hub,influence_amount)
	return true
