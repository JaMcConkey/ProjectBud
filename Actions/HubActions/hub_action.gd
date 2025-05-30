extends GameAction
class_name HubAction

var source_hub: Hub

#NOTE - Cost for hub actions will be Influence cost

func _init(p_name: String, p_icon: Texture2D, p_type: String, p_team : Team, p_source: Hub, p_requires_target: bool = true, p_cost: int = 0):
	super(p_name, p_icon, p_type,p_team, p_requires_target, p_cost)
	source_hub = p_source

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
		print("Not enough influence, or cost not high enough")
		return false
	
	if requires_target and target_hub == null:
		print("required a target, and no target set")
		return false
		
	return true

func execute() -> bool:
	if not super.execute():
		return false
		
	if cost > 0:
		if not source_hub.take_blob_influence(cost):
			print("Source Hub - " , source_hub, "Did not have enough influence")
			return false
	
	return true
