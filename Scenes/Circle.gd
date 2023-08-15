extends Node2D

@export var radius: float = 1
@export var resolution: int = 50
@export var breadth: float = 10

func _draw():
	draw_empty_circle(Vector2(0,0), radius, Color.WHITE, resolution, breadth)


func draw_empty_circle(circle_center: Vector2, r: float, color: Color, stroke_nb: int, width: float):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	var circle_radius = Vector2(0, r)
	line_origin = circle_radius + circle_center

	while draw_counter <= 360:
		line_end = circle_radius.rotated(deg_to_rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color, width)
		draw_counter += (1. / stroke_nb) * 360
		line_origin = line_end

	line_end = circle_radius.rotated(deg_to_rad(360)) + circle_center
	draw_line(line_origin, line_end, color, width)
