extends Node
class_name BattleController

# Controllers / Managers
@export var battlefield : Battlefield
@export var hub_controller : HubController
@export var action_manager : ActionManager
@export var influence_Manager : InfluenceManager

var game_context : GameContext
var _cur_mode : STATE
@export var teams : Array[Team]

# Selection info
var _selected_hub : Node = null
var _hovered_hub : Node = null
var _drag_source_hub : Node = null  # Hub we're dragging from
var _drag_target_hub : Node = null   # Hub we're dragging to
var _drag_in_progress : bool = false
var _drag_start_position : Vector2

enum STATE {
	Idle,              
	TargetSelection,   
	HubSelected,
	DragSelection      # Special state for drag-to-target
}

func _ready() -> void:
	start_battle()
	game_context = GameContext.new(self)
	_cur_mode = STATE.Idle
	action_manager.target_selection_started.connect(_action_started)
	action_manager.action_completed.connect(_action_ended)
	action_manager.action_failed.connect(_action_ended)

func start_battle():
	hub_controller.setup_hub_controller(self)

func _action_started(action : GameAction):
	_set_mode(STATE.TargetSelection)
	_clear_selection()
	if action is HubAction:
		action.source_hub.select_node()
		action.source_hub.highlight_action(action)  # Highlight the active action

func _action_ended(action : GameAction):
	_set_mode(STATE.Idle)
	_clear_selection()

func _set_mode(state : STATE):
	print("Changing mode to: ", STATE.keys()[state])
	if state == STATE.Idle:
		_clear_selection()
	_cur_mode = state

func _clear_selection():
	if _selected_hub:
		_selected_hub.deselect_node()
		_selected_hub = null
	if _drag_source_hub:
		_drag_source_hub.end_drag()
		_drag_source_hub = null
	if _drag_target_hub:
		_drag_target_hub = null
	for hub in hub_controller.get_all_hubs():
		hub.deselect_node()
		hub.clear_action_highlight()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('test'):
		var sender = hub_controller.get_all_hubs().pick_random()
		var rec = hub_controller.get_all_hubs().pick_random()
		influence_Manager.send_influence(sender, rec, 5)

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse button press
	if event.is_action_pressed("LeftClick"):
		var clicked_hub = _get_hub_under_mouse()
		
		if clicked_hub:
			if _cur_mode == STATE.Idle:
				_selected_hub = clicked_hub
				_selected_hub.select_node()
				_set_mode(STATE.HubSelected)
				_drag_source_hub = clicked_hub
				_drag_start_position = clicked_hub.get_global_mouse_position()
				_drag_in_progress = false
			
			elif _cur_mode == STATE.TargetSelection:
				action_manager.select_hub_target(clicked_hub)
				_set_mode(STATE.Idle)
			
			elif _cur_mode == STATE.HubSelected:
				if clicked_hub == _selected_hub:
					_clear_selection()
					_set_mode(STATE.Idle)
				else:
					_clear_selection()
					_selected_hub = clicked_hub
					_selected_hub.select_node()
	
	# Handle mouse button release
	if event.is_action_released("LeftClick"):
		if _drag_source_hub and _drag_in_progress:
			var target_hub = _get_hub_under_mouse()
			if target_hub and target_hub != _drag_source_hub:
				# Execute the first action (usually send influence)
				var actions = _drag_source_hub.get_hub_actions()
				if actions.size() > 0:
					var first_action = actions[0]
					first_action.target_hub = target_hub
					action_manager.start_action(first_action)
			
			_drag_source_hub.end_drag()
			_drag_source_hub = null
			_drag_in_progress = false
			_set_mode(STATE.Idle)
	
	# Handle mouse motion for drag detection
	if event is InputEventMouseMotion and _drag_source_hub and not _drag_in_progress:
		if (_drag_source_hub.get_global_mouse_position() - _drag_start_position).length() > 10:  # Drag threshold
			_drag_in_progress = true
			_drag_source_hub.start_drag()
			_set_mode(STATE.DragSelection)
	
	# Escape to cancel any mode
	if event.is_action_pressed("ui_cancel"):
		if _cur_mode != STATE.Idle:
			action_manager.cancel_current_action()
			_clear_selection()
			_set_mode(STATE.Idle)

func _get_hub_under_mouse() -> Node:
	for hub in hub_controller.get_all_hubs():
		if hub.mouse_over:
			return hub
	return null

func _handle_idle_click():
	var clicked_hub = _get_hub_under_mouse()
	if clicked_hub:
		_selected_hub = clicked_hub
		_selected_hub.select_node()
		_set_mode(STATE.HubSelected)

func _handle_target_selection_click():
	var clicked_hub = _get_hub_under_mouse()
	if clicked_hub:
		action_manager.select_hub_target(clicked_hub)
		_set_mode(STATE.Idle)
	else:
		action_manager.select_position_target(get_viewport().get_mouse_position())

func _handle_hub_selected_click():
	var clicked_hub = _get_hub_under_mouse()
	if clicked_hub:
		if clicked_hub == _selected_hub:
			_clear_selection()
			_set_mode(STATE.Idle)
		else:
			_clear_selection()
			_selected_hub = clicked_hub
			_selected_hub.select_node()
