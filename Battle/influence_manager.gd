extends Node
class_name InfluenceManager

@export var influence_blob_scene : PackedScene
var active_blobs : Array[InfluenceBlob]
#
#func _ready() -> void:
	#SignalBus.blob_hub_collide.connect(merge_influence_blob_to_hub)

func can_send_influence(node : Hub) -> bool:
	"""
	Scans the Hub for a sender, and makes sure value > 0 
	"""
	for child in node.get_hub_components():
		if child is InfluenceSender and node.get_current_influence() > 0:
			return true
	return false
func send_influence(send_hub : Hub,target_hub : Hub,send_amount : int):
	if send_hub == target_hub:
		push_warning("Hub should not send to self")
		return
	if can_send_influence(send_hub) and can_receive_influence(target_hub)\
	and send_amount > 0:
		#Attempt to take the influence - 
		#if send_hub.take_blob_influence(send_amount): -Removed this, as the ACTION
		# is currently removing the cost
		var blob = influence_blob_scene.instantiate() as InfluenceBlob
		#Add sending hub to ignore list
		blob.ignore_hub(send_hub)
		#Connect signals
		blob.on_hub_collide.connect(merge_influence_blob_to_hub)
		blob.on_blob_collide.connect(blob_on_blob)
			
		blob.global_position = send_hub.global_position
		blob.init_blob(send_hub.team_owner,send_amount,target_hub)
		active_blobs.append(blob)
		add_child(blob)
			
func can_receive_influence(hub : Hub) -> bool:
	for child in hub.get_hub_components():
		if child is InfluenceReceiver:
			return true
	return false
func receive_influnce(amount : int,team : Team, r_hub : Hub):
	"""
	Receiving hub most have an influence receiver
	"""
	#NOTE Receive method is only for triggers, adjust manually in hub
	for child in r_hub.get_hub_components():
		if child is InfluenceReceiver:
			child.receive_influence(amount)
			r_hub.apply_influence(amount,team)
func merge_influence_blob_to_hub(blob : InfluenceBlob,receiving_hub : Hub):
	receiving_hub.apply_influence(blob.influence_value,blob.get_team())
	remove_blob(blob)
func blob_on_blob(blob_a : InfluenceBlob,blob_b:InfluenceBlob):
	var dif = blob_a.influence_value - blob_b.influence_value
	if dif == 0:
		remove_blob(blob_a)
		remove_blob(blob_b)
	elif dif > 0:
		blob_a.influence_value = dif
		remove_blob(blob_b)
	else:
		blob_b.influence_value = abs(dif)
		remove_blob(blob_a)
func remove_blob(blob : InfluenceBlob):
	active_blobs.erase(blob)
	blob.destroy_blob()

func _physics_process(delta: float) -> void:
	for blob in active_blobs:
		blob.move(delta)
