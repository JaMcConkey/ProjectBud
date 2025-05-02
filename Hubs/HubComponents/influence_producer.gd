extends HubComponent
class_name InfluenceProducer

var _time_to_produce : float = .5
var _amount : int = 1
var _timer : float
func _physics_process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
	if _timer <= 0:
		if hub:
			hub.apply_influence(_amount, hub.team_owner)
			_timer = _time_to_produce
