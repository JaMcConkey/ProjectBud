extends HubAction
class_name AttackAction

enum ATTACK_TYPE{
	PROJECTILE,
	BEAM
}

func _init(source: Hub, attack_comp : AttackComponent):
	super(source)
	requires_target = true
	if source.team_owner.is_ai:
		#Set collisions on projectile to player
		pass

func execute() -> bool:
	if not super.execute():
		return false
	return true
