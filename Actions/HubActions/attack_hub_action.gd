extends HubAction
class_name SendAttackAction

var _damage_amount : int

func _init(source: Hub, attack_comp : AttackComponent):
	super(source)
	requires_target = true
	if source.team_owner.is_ai:
		#Set collisions on projectile to player
		pass

func execute() -> bool:
	return super.execute()
