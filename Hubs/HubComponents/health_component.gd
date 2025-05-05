extends HubComponent
class_name HealthComponent

signal health_updated()
signal health_depleted()

var max_health : int
var cur_health : int

func damage(amount : int):
	cur_health = clampi(cur_health - amount,0,max_health)
	if cur_health <= 0:
		health_depleted.emit()
	health_updated.emit()
	
func heal(amount : int):
	cur_health = clampi(cur_health + amount,0,max_health)
	health_updated.emit()
