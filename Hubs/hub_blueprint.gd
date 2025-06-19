extends Resource
class_name HubBlueprint

@export_group("Influence")
@export var max_influence : int = 30
@export var can_send_influence : bool
@export var can_recieve_influence : bool
@export var influence_production_speed : float # 0 = no production

@export_group("Combat")
@export var health : float
@export var can_attack : bool
