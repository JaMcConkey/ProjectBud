extends Camera2D


func _process(_delta: float) -> void:
	self.global_position = $"../BattleField".get_center()
