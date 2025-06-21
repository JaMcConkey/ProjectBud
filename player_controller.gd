extends Node

enum MODE{
	BATTLE,
	IDLE
}
#
#var _selected_nodes : Array[Hub]
#var held : bool
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("LeftClick"):
		#for hub in _selected_nodes:
			#hub.deselect_node()
		#_selected_nodes.clear()
		#for hub in get_tree().get_nodes_in_group("hubs"):
			#if hub is Hub:
				#if hub.mouse_over:
					#hub.select_node()
					#held = true
	#if event.is_action_released("LeftClick"):
		#for hub in get_tree().get_nodes_in_group("hubs"):
			#if hub is Hub:
				#if hub.mouse_over:
					#pass
		#held = false
