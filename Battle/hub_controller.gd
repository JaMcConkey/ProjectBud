extends Node
class_name HubController
@export var hub_scene : PackedScene
var _hub_positions : Array[Vector2]
var _battlefield : Battlefield
var _battle_controller : BattleController
var _hubs : Array[Hub]

func setup_hub_controller(battle_controller : BattleController):
	_battle_controller = battle_controller
	_battlefield = battle_controller.battlefield
	_generate_hub_positions()
	_place_starting_hubs()

func _generate_hub_positions():
	for i in 5:
		var x = randf_range(0,_battlefield.arena_size.x)
		var y = randf_range(0,_battlefield.arena_size.y)
		_hub_positions.append(Vector2(x,y))
func _place_starting_hubs():
	for point in _hub_positions:
		place_hub(point)
func place_hub(pos : Vector2):
	var hub = hub_scene.instantiate()
	if hub is Hub:
		hub.global_position = pos
		add_child(hub)
		_hubs.append(hub)
		#TESTING
		hub.init_hub(_battle_controller)
		var inf_s = InfluenceSender.new()
		var inf_r = InfluenceReceiver.new()
		var inf_p = InfluenceProducer.new()
		hub.add_hub_component(inf_p)
		hub.add_hub_component(inf_s)
		hub.add_hub_component(inf_r)
		hub.apply_influence(50,Team.new())
		hub.set_team(_battle_controller.teams.pick_random())
	else:
		push_error("Scene wasn't a hub???")
		return

func get_all_hubs() -> Array[Hub]:
	return _hubs
