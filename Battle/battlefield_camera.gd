extends Camera2D

# Camera movement settings
@export var drag_sensitivity := 1.0
@export var edge_scroll_enabled := false
@export var edge_scroll_margin := 50.0
@export var edge_scroll_speed := 500.0

# Zoom settings
@export var zoom_sensitivity := 0.1
@export var min_zoom := 0.3
@export var max_zoom := 3.0
@export var zoom_step := 0.1

# Private variables
var _dragging := false
var _drag_start_position := Vector2.ZERO
var _camera_start_position := Vector2.ZERO
var _is_enabled : bool = false
func _ready():
	# Make sure the camera processes even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if edge_scroll_enabled:
		_handle_edge_scrolling(delta)

func _unhandled_input(event):
	if event.is_action_pressed("camera_toggle"):
		_is_enabled = true
	if event.is_action_released("camera_toggle"):
		_is_enabled = false
	if not _is_enabled:
		return
	# Camera dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or (event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SPACE)):
			if event.pressed:
				_dragging = true
				_drag_start_position = get_global_mouse_position()
				_camera_start_position = position
			else:
				_dragging = false
				
	# Camera zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_step)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_step)
	
	# Continue dragging if already started
	if _dragging and event is InputEventMouseMotion:
		var drag_offset = (_drag_start_position - get_global_mouse_position()) * drag_sensitivity
		position = _camera_start_position + drag_offset

func zoom_camera(zoom_change: float):
	var new_zoom = zoom + Vector2.ONE * zoom_change
	new_zoom = new_zoom.clamp(Vector2.ONE * min_zoom, Vector2.ONE * max_zoom)
	
	# Optional: zoom toward mouse position
	var mouse_world_pos_before = get_global_mouse_position()
	zoom = new_zoom
	var mouse_world_pos_after = get_global_mouse_position()
	position += (mouse_world_pos_before - mouse_world_pos_after)

func _handle_edge_scrolling(delta):
	var viewport = get_viewport()
	if not viewport: return
	
	var mouse_pos = viewport.get_mouse_position()
	var viewport_size = viewport.size
	
	var move_dir := Vector2.ZERO
	
	if mouse_pos.x < edge_scroll_margin:
		move_dir.x -= 1
	if mouse_pos.x > viewport_size.x - edge_scroll_margin:
		move_dir.x += 1
	if mouse_pos.y < edge_scroll_margin:
		move_dir.y -= 1
	if mouse_pos.y > viewport_size.y - edge_scroll_margin:
		move_dir.y += 1
	
	if move_dir != Vector2.ZERO:
		position += move_dir.normalized() * edge_scroll_speed * delta * (1.0 / zoom.x)
