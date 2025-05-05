extends Resource
class_name GameContext

var battle_controller : BattleController
var player_team : Team

func _init(p_battle_controller : BattleController) -> void:
	battle_controller = p_battle_controller
