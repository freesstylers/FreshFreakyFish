extends Node2D
class_name FishSpawnManager

@export var fish_scene: PackedScene
@export var water_body: WaterBody
@export var initial_fish_count: int = 10
@export var min_fish_count: int = 5
@export var max_fish_count: int = 20
@export var min_fish_scale: float = 0.5
@export var max_fish_scale: float = 1.5

var current_fish_count: int = 0

@onready var FishesSpawnedPool = $FishesSpawnedPool

func _ready():
	spawn_initial_fish()
	GameManagerScript.game_over.connect(fish_caught)

func _process(delta):
	if current_fish_count < min_fish_count:
		spawn_fish()

func spawn_initial_fish():
	for i in range(initial_fish_count):
		spawn_fish()

func spawn_fish():
	if current_fish_count < max_fish_count:
		var fish_instance = fish_scene.instantiate() as FishBase
		var spawn_position = get_random_spawn_position()
		
		# Randomize the scale of the fish
		var random_scale = randf_range(min_fish_scale, max_fish_scale)
		fish_instance.scale = Vector2(random_scale, random_scale)
		
		fish_instance.set_water_body(water_body)
		FishesSpawnedPool.add_child(fish_instance)
		fish_instance.global_position = spawn_position
		fish_instance.set_new_target()
		current_fish_count += 1

func get_random_spawn_position():
	if water_body == null:
		return Vector2.ZERO
	return water_body.get_random_position_inside_polygon()

func fish_caught(caught : bool ):
	current_fish_count -= 1

func on_spawn_timer_finished():
	var space_left = max_fish_count - current_fish_count
	for i in range(space_left):
		spawn_fish()
