extends Node
class_name BattleController

#Controllers / MAnagers
@export var battlefield : Battlefield
@export var hub_controller : HubController
@export var action_manager : ActionManager
@export var influence_Manager : InfluenceManager

@export var targeting_UI : TargetingUI

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
	action_manager.target_requested.connect(_targeting_started)
	#action_manager.action_completed.connect(_action_ended)
	#action_manager.action_failed.connect(_action_ended)

func _physics_process(delta: float) -> void:
	if is_dragging:
		_drag_timer += delta

func start_battle():
	hub_controller.setup_hub_controller(self)

func _targeting_started(action : GameAction, _requester_id : String):
	_set_mode(STATE.TargetSelection)
	targeting_UI.show_targeting_ui(action)
	#NOTE Make sure to clear old action stuffs
	#_clear_selection()
	if action is HubAction:
		#Make sure no other nodes are selected for some reason
		#NOTE select_node() should have already been called here on the hub,
		#Will need to handle if it's not a player selected hub action later
		for hub in hub_controller.get_all_hubs():
			if hub == action.source_hub:
				continue
			hub.deselect_node()
			hub.toggle_targetable_icon(false)

		selected_hub = action.source_hub
		for hub in hub_controller.get_all_hubs():
				hub.toggle_targetable_icon(action.is_valid_target(hub))

func _action_ended(_action : GameAction):
	for hub in hub_controller.get_all_hubs():
		hub.toggle_targetable_icon(false)
	_set_mode(STATE.Idle)
	_clear_selection()

func _set_mode(state : STATE):
	print("Changing mode to: ", STATE.keys()[state])
	if _cur_mode == STATE.TargetSelection and state != STATE.TargetSelection:
		targeting_UI.hide_targeting_ui()
	if state == STATE.Idle:
		_clear_selection()
	_cur_mode = state

func _clear_selection():
	if selected_hub:
		selected_hub.deselect_node()
		selected_hub = null
	for hub in hub_controller.get_all_hubs():
		hub.deselect_node()
		hub.toggle_targetable_icon(false)

func _input(event: InputEvent) -> void:
	# Escape to idle for now
	if event.is_action_pressed("ui_cancel"):
		if _cur_mode != STATE.Idle:
			action_manager.cancel_target_request()
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
			var active_comp = selected_hub.get_active_component()
			if active_comp != null:
				active_comp.decrease()

	if event.is_action_pressed("ScrollUp"):
		if selected_hub:
			var active_comp = selected_hub.get_active_component()#hub_ui.get_active_component()
			if active_comp != null:
				active_comp.increase()
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
		if action_manager.provide_target(clicked_hub):
			_set_mode(STATE.Idle)
	else:
		if action_manager.provide_target(get_viewport().get_mouse_position()):
			_set_mode(STATE.Idle)

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
