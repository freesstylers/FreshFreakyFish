extends Node2D
class_name FishBase

@export var speed: float = 50.0          
@export var normal_speed: float = 50.0          
@export var min_hunting_speed: float = 80.0          
@export var max_hunting_speed: float = 200.0          
@export var scared_speed: float = 900.0          
@export var rotation_speed = 5.0 
@export var min_wander_range: float = 100.0  
@export var max_wander_range: float = 500.0  

const TARGET_REACHED_THRESHOLD = 10
const MIN_SPAWN_FADE_IN_DURATION = 1.5
const MAX_SPAWN_FADE_IN_DURATION = 5

# Internal variables
var target_pos : Vector2 = Vector2.ZERO
var current_rotation: float = 0.0
var water_body: WaterBody = null

var focused : bool = false
var focused_on_hook : bool = false
var focused_distance : float = 30
var I_Got_Hooked : bool = false

@onready var FishSprite : Sprite2D = $FishSprite
@onready var MouthNode : Node2D = $Mouth

func _ready():
	set_new_target()
	var local_tween = create_tween()
	FishSprite.modulate.a = 0
	local_tween.tween_property(FishSprite, "modulate:a", 1, randf_range(MIN_SPAWN_FADE_IN_DURATION, MAX_SPAWN_FADE_IN_DURATION))
	GameManagerScript.game_fish_selected.connect(on_some_fish_got_hooked)

func _process(delta):
	var dir = target_pos-global_position
	global_position += dir.normalized() * speed * delta
	var target_rotation = dir.angle() + PI / 2
	current_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
	rotation = current_rotation
	
	if focused:
		if (MouthNode.global_position - target_pos).length() < focused_distance:
			if(focused_on_hook):
				GameManagerScript.game_start_playing.emit()
				I_Got_Hooked = true
				queue_free()
			else:
				focused = false
				speed = normal_speed
	else:
		if global_position.distance_to(target_pos) < TARGET_REACHED_THRESHOLD:
			set_new_target()

func set_water_body(water_body_node):
	water_body = water_body_node

func set_new_target():
	var random_position = generate_random_valid_position()
	if random_position != Vector2.ZERO:
		target_pos = random_position

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

func Get_Scared(run_pos):
	focused = true
	target_pos = run_pos
	speed = scared_speed

func Hunt(hunting_dest):
	focused_on_hook = true
	focused = true
	target_pos = hunting_dest
	speed = randf_range(min_hunting_speed, max_hunting_speed)
	
func on_some_fish_got_hooked(level):
	if I_Got_Hooked:
		return
	focused = false
	focused_on_hook=false
	speed = normal_speed
	set_new_target()
