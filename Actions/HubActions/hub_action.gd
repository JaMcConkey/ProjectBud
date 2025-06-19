extends GameAction
class_name HubAction

var source_hub: Hub

#NOTE - Cost for hub actions will be Influence cost

func _init(p_source: Hub):
	source_hub = p_source
	super(p_source.team_owner)


func can_start() -> bool:
	"""
	Does not check for a target hub, checks if influence and cost are set
	"""
	return ( super.can_execute() and\
	 cost > 0 and\
	 source_hub.get_current_influence() >= cost)



func can_execute() -> bool:
	if not super.can_execute():
		return false
		
	# Hub-specific checks
	if cost > 0 and source_hub.get_current_influence() < cost:
		#print("Not enough influence, or cost not high enough")
		return false
	
	if requires_target and target_hub == null:
		#print("required a target, and no target set")
		return false
	return true


func execute() -> bool:
	if not super.execute():
		return false
		
	if cost > 0 and cost > source_hub.get_current_influence():
		print("Source Hub - " , source_hub, "Did not have enough influence")
		return false
	#source_hub.consume_influence(cost)
	return true
