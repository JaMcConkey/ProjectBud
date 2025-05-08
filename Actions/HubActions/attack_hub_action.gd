extends HubAction
class_name AttackHubAction

func _init(source: Hub, attack_comp : AttackComponent):
	super("Send Influence", null, "send_influence", source, true, attack_comp.attack_cost)

	requires_target = true

func execute() -> bool:
	if not super.execute():
		return false
	return true
