extends Node2D
class_name FishBase

@export var speed: float = 50.0          
@export var rotation_speed = 5.0 
@export var min_wander_range: float = 100.0  
@export var max_wander_range: float = 500.0  

const TARGET_REACHED_THRESHOLD = 10
const MIN_SPAWN_FADE_IN_DURATION = 1.5
const MAX_SPAWN_FADE_IN_DURATION = 5


# Internal variables
var target_position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO  
var current_rotation: float = 0.0
var water_body: WaterBody = null

var hunting : bool = false
var hunting_pos : Vector2 = Vector2.ZERO
var hunting_distance : float = 10

@onready var FishSprite : Sprite2D = $FishSprite
@onready var MouthNode : Node2D = $Mouth

func _ready():
	spawn()

func _process(delta):
	if not hunting:
		# Move towards wander destination
		global_position += direction.normalized() * speed * delta
		var target_rotation = direction.angle() + PI / 2
		current_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
		rotation = current_rotation

		# Check if reached target position
		if global_position.distance_to(target_position) < TARGET_REACHED_THRESHOLD:
			set_new_target()
	else:
		var hunting_dir = hunting_pos-global_position
		# Move towards wander destination
		global_position += hunting_dir.normalized() * speed * delta
		var target_rotation = hunting_dir.angle() + PI / 2
		current_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
		rotation = current_rotation
		Check_Hook()

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

func spawn():
	set_new_target()
	var local_tween = create_tween()
	FishSprite.modulate.a = 0
	local_tween.tween_property(FishSprite, "modulate:a", 1, randf_range(MIN_SPAWN_FADE_IN_DURATION, MAX_SPAWN_FADE_IN_DURATION))


func Hunt(hunting_dest):
	hunting = true
	hunting_pos = hunting_dest

func Check_Hook():
	if (MouthNode.global_position - hunting_pos).length() < hunting_distance:
		GameManagerScript.game_start_playing.emit()
		queue_free()
