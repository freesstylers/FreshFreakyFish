extends Node2D
class_name FishBase

@export var speed: float = 50.0          
@export var rotation_speed = 5.0 
@export var min_wander_range: float = 100.0  
@export var max_wander_range: float = 500.0  

const TARGET_REACHED_THRESHOLD = 10

# Internal variables
var target_position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO  
var current_rotation: float = 0.0
var water_body: WaterBody = null

func _ready():
	set_new_target()

func _process(delta):
	# Move towards wander destination
	global_position += direction.normalized() * speed * delta
	var target_rotation = direction.angle() + PI / 2
	current_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
	rotation = current_rotation

	# Check if reached target position
	if global_position.distance_to(target_position) < TARGET_REACHED_THRESHOLD:
		set_new_target()

func set_water_body(water_body_node):
	water_body = water_body_node

func set_new_target():
	var random_position = generate_random_valid_position()
	if random_position != Vector2.ZERO:
		target_position = random_position
		direction = (target_position - global_position).normalized()

func generate_random_valid_position():
	var random_angle = randf_range(0, 360)
	var direction_vector = Vector2.RIGHT.rotated(deg_to_rad(random_angle))
	var candidate_position = global_position + direction_vector * randf_range(min_wander_range, max_wander_range)
	#Check for boundaries if we have a water body
	if water_body:
		while not water_body.is_point_inside_polygon(candidate_position):
			random_angle = randf_range(0, 360)
			direction_vector = Vector2.RIGHT.rotated(deg_to_rad(random_angle))
			candidate_position = global_position + direction_vector * randf_range(min_wander_range, max_wander_range)
	return candidate_position