extends Node

@export var ActivityAreaScene : PackedScene = null
@export var WaterSensorPixelSize : int = 20
@export var InitialForce : float = 100.0  # Initial force of the water drop
@export var FadeFactor : float = 0.7  # Factor by which force fades with each step

@onready var WaterBodyArea = $WaterBodyArea
@onready var NodesPool = $NodesPool
@onready var WaterSensorTopLeftSpawnLimit = $TopLeftLimit
@onready var WaterSensorBottomRightSpawnLimit = $BottomRightLimit
@onready var areaPolygon : CollisionPolygon2D = $WaterBodyArea/CollisionPolygon2D

var sensor_grid = []

func _ready():
	prepare_activity_area()
	connect_sensor_neighbors()
	disable_sensors_outside_of_water_body()

func _input(event):
	if event is InputEventMouseButton:
		var mouse_button_event = event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed:
			var mouse_position = get_viewport().get_mouse_position()
			var clicked_sensor = get_sensor_at_position(mouse_position)
			if clicked_sensor:
				spread_water_drop(clicked_sensor.x, clicked_sensor.y, InitialForce)

func get_sensor_at_position(pos: Vector2):
	var col = int((pos.x - WaterSensorTopLeftSpawnLimit.global_position.x) / WaterSensorPixelSize)
	var row = int((pos.y - WaterSensorTopLeftSpawnLimit.global_position.y) / WaterSensorPixelSize)
	if row < 0 or row >= sensor_grid.size() or col < 0 or col >= sensor_grid[row].size():
		return null
	return Vector2(row,col)

func prepare_activity_area():
	# Get the top-left and bottom-right positions
	var top_left = WaterSensorTopLeftSpawnLimit.global_position
	var bottom_right = WaterSensorBottomRightSpawnLimit.global_position

	# Calculate the number of rows and columns
	var width = bottom_right.x - top_left.x
	var height = bottom_right.y - top_left.y
	var cols = int(width / WaterSensorPixelSize)
	var rows = int(height / WaterSensorPixelSize)

	sensor_grid.resize(rows)
	for row in range(rows):
		sensor_grid[row] = []
		for col in range(cols):
			var position = Vector2(
				top_left.x + col * WaterSensorPixelSize + WaterSensorPixelSize / 2,
				top_left.y + row * WaterSensorPixelSize + WaterSensorPixelSize / 2
			)
			var sensor = spawn_sensor(position)
			sensor_grid[row].append(sensor)

func spawn_sensor(position: Vector2) -> ActivityArea:
	var sensor = ActivityAreaScene.instantiate()
	NodesPool.add_child(sensor)
	sensor.global_position = position
	sensor.scale = Vector2(WaterSensorPixelSize, WaterSensorPixelSize)
	return sensor

func connect_sensor_neighbors():
	# Connect neighboring areas in a grid
	for row in range(sensor_grid.size()):
		for col in range(sensor_grid[row].size()):
			var above_sensor = null
			var below_sensor = null
			var left_sensor = null
			var right_sensor = null
			
			if row > 0:
				above_sensor = sensor_grid[row - 1][col]
			if row < sensor_grid.size() - 1:
				below_sensor = sensor_grid[row + 1][col]
			if col > 0:
				left_sensor = sensor_grid[row][col - 1]
			if col < sensor_grid[row].size() - 1:
				right_sensor = sensor_grid[row][col + 1]
			
			sensor_grid[row][col].set_neighboring_areas(above_sensor, below_sensor, left_sensor, right_sensor)

func disable_sensors_outside_of_water_body():
	for row in sensor_grid:
		for sensor in row:
			if is_point_inside_polygon(sensor.global_position):
				sensor.visible = true
			else:
				sensor.visible = false

func spread_water_drop(start_row: int, start_col: int, force: float):
	var queue = []
	queue.append({r = start_row, c = start_col, f = force})
	var visited = []
	visited.resize(sensor_grid.size())  # Resize the main array
	for row in range(sensor_grid.size()):
		visited[row] = []
		visited[row].resize(sensor_grid[row].size())  # Resize each inner array
	#Manhattan traverse
	while queue.size() > 0:
		var queue_elem = queue.pop_front()	
		# Add activity to the current sensor if not visited
		if not visited[queue_elem.r][queue_elem.c]:
			var current_sensor = sensor_grid[queue_elem.r][queue_elem.c]
			current_sensor.AddActivity(queue_elem.f)
			visited[queue_elem.r][queue_elem.c] = true
			var neighbors = [
				Vector2(queue_elem.r - 1, queue_elem.c),  # Up
				Vector2(queue_elem.r + 1, queue_elem.c),  # Down
				Vector2(queue_elem.r, queue_elem.c - 1),  # Left
				Vector2(queue_elem.r, queue_elem.c + 1)   # Right
			]
			for neighbor in neighbors:
				var n_row = int(neighbor.x)
				var n_col = int(neighbor.y)
				#Only if inside the grid
				if n_row >= 0 and n_row < sensor_grid.size() and n_col >= 0 and n_col < sensor_grid[n_row].size():
					var next_sensor = sensor_grid[n_row][n_col]
					#Only if not visited yet
					if not visited[n_row][n_col] and queue_elem.f * FadeFactor > 0.1:
						queue.append({r = n_row, c = n_col, f = queue_elem.f * FadeFactor})

func is_point_inside_polygon(point: Vector2) -> bool:
	var polygonVertices = areaPolygon.polygon
	var transform = areaPolygon.global_transform
	var vertices_global_positions = []
	for local_point in polygonVertices:
		var global_point = transform.origin + transform.basis_xform(local_point)
		vertices_global_positions.append(global_point)
	# Check if the point is inside the polygon
	return Geometry2D.is_point_in_polygon(point, vertices_global_positions)
