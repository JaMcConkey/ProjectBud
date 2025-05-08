extends Control
class_name HubHealthUI

var health_comp : HealthComponent
@export var health_bar : ProgressBar

func bind_health_component(p_health_component : HealthComponent):
	if health_bar != null:
		push_warning("health comp already bound")
		return
	health_comp = p_health_component
	health_comp.health_updated.connect(_update_health)

func _update_health():
	health_bar.max_value = health_comp.max_health
	health_bar.value = health_comp.cur_health
