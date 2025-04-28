extends HubComponent
class_name InfluenceSender


func get_all_actions() -> Array[GameAction]:
	var send_action = SendInfluenceAction.new(hub,(hub.get_current_influence() / 2))
	var r_arr : Array[GameAction]
	r_arr.append(send_action)
	return r_arr
