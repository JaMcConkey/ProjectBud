extends Node2D

@export var lanes: int = 8 


var show_lanes : bool :
	set(v):
		if v:
			pass

func _ready():
	#draw_grid()
	pass
func draw_grid():
	var viewport_size = get_viewport_rect().size
	var width = viewport_size.x
	var height = viewport_size.y

	if lanes < 1:
		return  
	var spacing = width / float(lanes)

	for i in range(lanes + 1):
		var x = i * spacing
		var line = Line2D.new()
		line.add_point(Vector2(x, 0))
		line.add_point(Vector2(x, height))
		line.width = 2
		line.default_color = Color(1, 1, 1, 0.5)
		add_child(line)
