class_name WaterBody
extends Node

@onready var areaPolygon : CollisionPolygon2D = $WaterBodyArea/CollisionPolygon2D

func is_point_inside_polygon(point: Vector2) -> bool:
	var polygonVertices = areaPolygon.polygon
	var transform = areaPolygon.global_transform
	var vertices_global_positions = []
	for local_point in polygonVertices:
		var global_point = transform.origin + transform.basis_xform(local_point)
		vertices_global_positions.append(global_point)
	# Check if the point is inside the polygon
	return Geometry2D.is_point_in_polygon(point, vertices_global_positions)

func get_random_position_inside_polygon():
	var polygon_vertices = areaPolygon.polygon
	var global_transform = areaPolygon.global_transform
	var vertices_global_positions = []
	for local_point in polygon_vertices:
		var global_point = global_transform.origin + global_transform.basis_xform(local_point)
		vertices_global_positions.append(global_point)

	var min_x = vertices_global_positions[0].x
	var min_y = vertices_global_positions[0].y
	var max_x = vertices_global_positions[0].x
	var max_y = vertices_global_positions[0].y

	for vertex in vertices_global_positions:
		min_x = min(min_x, vertex.x)
		min_y = min(min_y, vertex.y)
		max_x = max(max_x, vertex.x)
		max_y = max(max_y, vertex.y)
	var random_point = Vector2(randf_range(min_x, max_x),randf_range(min_y, max_y))
	while not is_point_inside_polygon(random_point):
		random_point = Vector2(randf_range(min_x, max_x),randf_range(min_y, max_y))
	return random_point
