extends Node
class_name BattleController

#Controllers / MAnagers
@export var battlefield : Battlefield
@export var hub_controller : HubController
@export var action_manager : ActionManager
@export var influence_Manager : InfluenceManager

var game_context : GameContext
var _cur_mode : STATE
@export var teams : Array[Team]

var send_value : int :
	set(v):
		send_value = abs(v)

#Selection info
var selected_hub : Hub = null
var _hovered_hub : Hub = null
var is_dragging : bool
var _drag_threshold : float = 0.2
var _drag_timer : float = 0

enum STATE {
	Idle,              
	TargetSelection,   
	HubSelected        
}

func _ready() -> void:
	start_battle()
	game_context = GameContext.new(self)
	_cur_mode = STATE.Idle
	action_manager.player_target_selection_started.connect(_action_started)
	#action_manager.action_completed.connect(_action_ended)
	#action_manager.action_failed.connect(_action_ended)

func _physics_process(delta: float) -> void:
	if is_dragging:
		_drag_timer += delta

func start_battle():
	hub_controller.setup_hub_controller(self)

func _action_started(action : GameAction):
	_set_mode(STATE.TargetSelection)
	#NOTE Make sure to clear old action stuffs
	_clear_selection()
	if action is HubAction:
		action.source_hub.select_node()
		selected_hub = action.source_hub

func _action_ended(_action : GameAction):
	_set_mode(STATE.Idle)
	_clear_selection()

func _set_mode(state : STATE):
	print("Changing mode to: ", STATE.keys()[state])
	if state == STATE.Idle:
		_clear_selection()
	_cur_mode = state

func _clear_selection():
	if selected_hub:
		selected_hub.deselect_node()
		selected_hub = null
	for hub in hub_controller.get_all_hubs():
		hub.deselect_node()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('test'):
		var sender = hub_controller.get_all_hubs().pick_random()
		var rec = hub_controller.get_all_hubs().pick_random()
		influence_Manager.send_influence(sender, rec, 5)
	# Escape to idle for now
	if event.is_action_pressed("ui_cancel"):
		if _cur_mode != STATE.Idle:
			#action_manager.cancel_current_action()
			_clear_selection()
			_set_mode(STATE.Idle)

func _unhandled_input(event: InputEvent) -> void:
	#doing down and released incase I decide to add dragging
	if event.is_action_pressed("LeftClick"):
		_handle_left_click_down()
	if event.is_action_released("LeftClick"):
		_handle_left_click_up()
	if event.is_action_pressed("ScrollDown"):
		if selected_hub:
			for comp in selected_hub.get_hub_components():
				if comp is InfluenceSender:
					comp.set_send_value(comp.get_send_value() - 1)
	if event.is_action_pressed("ScrollUp"):
		if selected_hub:
			for comp in selected_hub.get_hub_components():
				if comp is InfluenceSender:
					comp.set_send_value(comp.get_send_value() + 1)
func _handle_left_click_down():
	is_dragging = true
	match _cur_mode:
		STATE.Idle:
			_handle_idle_click()
		STATE.TargetSelection:
			_handle_target_selection_click()
		STATE.HubSelected:
			_handle_hub_selected_click()
func _handle_left_click_up():
	pass


func _handle_idle_click():
	var clicked_hub = null
	for hub in hub_controller.get_all_hubs():
		if hub.mouse_over:
			clicked_hub = hub
			break
	
	if clicked_hub:
		selected_hub = clicked_hub
		#NOTE: Selecting the node shows actions on the node
		selected_hub.select_node()
		_set_mode(STATE.HubSelected)
		

func _handle_target_selection_click():
	var clicked_hub = null
	for hub in hub_controller.get_all_hubs():
		if hub.mouse_over:
			clicked_hub = hub
			break
	
	if clicked_hub:
		action_manager.select_player_target(clicked_hub)
		_set_mode(STATE.Idle)
	else:
		action_manager.select_player_target(get_viewport().get_mouse_position())

func _handle_hub_selected_click():
	var clicked_hub = null
	for hub in hub_controller.get_all_hubs():
		if hub.mouse_over:
			clicked_hub = hub
			break
	
	# Clicking same hub deselects it for now-
	if clicked_hub:
		if clicked_hub == selected_hub:
			_clear_selection()
			_set_mode(STATE.Idle)
		else:
			_clear_selection()
			selected_hub = clicked_hub
			selected_hub.select_node()
