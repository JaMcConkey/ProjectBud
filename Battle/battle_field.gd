extends Node
class_name Battlefield


@export var arena_size: Vector2 = Vector2(800, 600)
@export var line_color: Color = Color.WHITE
@export var line_width: float = 4.0

func _ready():
	create_world_boundaries()
	create_visual_lines()

func get_center() -> Vector2:
	return arena_size / 2

func create_world_boundaries():
	var edges = {
		"top":    [Vector2(0, 0), Vector2(arena_size.x, 0)],
		"right":  [Vector2(arena_size.x, 0), Vector2(arena_size.x, arena_size.y)],
		"bottom": [Vector2(arena_size.x, arena_size.y), Vector2(0, arena_size.y)],
		"left":   [Vector2(0, arena_size.y), Vector2(0, 0)],
	}

	for edge_name in edges.keys():
		var start = edges[edge_name][0]
		var end = edges[edge_name][1]

		var body = StaticBody2D.new()
		body.name = "Boundary_" + edge_name
		body.position = Vector2.ZERO

		var shape = WorldBoundaryShape2D.new()
		shape.normal = (end - start).normalized().orthogonal().normalized()

		var collision = CollisionShape2D.new()
		collision.shape = shape
		collision.position = (start + end) / 2

		body.add_child(collision)
		add_child(body)

func create_visual_lines():
	var line = Line2D.new()
	line.width = line_width
	line.default_color = line_color
	line.closed = true

	line.add_point(Vector2(0, 0))
	line.add_point(Vector2(arena_size.x, 0))
	line.add_point(Vector2(arena_size.x, arena_size.y))
	line.add_point(Vector2(0, arena_size.y))

	add_child(line)
