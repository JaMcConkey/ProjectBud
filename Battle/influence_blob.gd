extends Area2D
class_name InfluenceBlob

signal on_hub_collide(self_blob : InfluenceBlob, hub : Hub)
signal on_blob_collide(self_blob : InfluenceBlob, other_blob : InfluenceBlob)

@export var inf_label : Label
@export var tar_line : Line2D
#Runtimes
var _team : Team
var influence_value : int :
	set(v):
		if inf_label:
			var val = v #Maybe set a cap here?
			inf_label.text = str(val)
			influence_value = val
var move_speed : float = 200
var _target : Node2D
var _ignored_hubs : Array[Hub]

func set_team(team : Team):
	#Collision layer is set based on is AI team flag
	if team.is_ai:
		set_collision_layer_value(4,true)
		set_collision_mask_value(3,true)
	else:
		set_collision_layer_value(3,true)
		set_collision_mask_value(4,true)
	_team = team
func get_team() -> Team:
	return _team
func init_blob(team : Team, influence_amount : int, target_node : Node2D):
	set_team(team)
	set_influence(influence_amount)
	set_target(target_node)
	area_entered.connect(check_collision)
func set_influence(val : int):
	influence_value = val
func set_target(node : Node2D):
	_target = node

func move(delta : float):
	global_position += global_position.direction_to(_target.global_position) * move_speed * delta
	#tar_line.points = [Vector2.ZERO,to_local(_target.global_position)]
func check_collision(area : Area2D):
	if area is InfluenceBlob:
		on_blob_collide.emit(self,area)
		#SignalBus.blob_collide_blob.emit(self,area)
	if area is HubCollider:
		var hub = area.get_parent()
		if hub == _target:
			if hub and hub is Hub and not _ignored_hubs.has(hub):
				on_hub_collide.emit(self,hub)
				#SignalBus.blob_hub_collide.emit(self,hub)

func ignore_hub(hub : Hub):
	_ignored_hubs.append(hub)

func destroy_blob():
	self.queue_free()
