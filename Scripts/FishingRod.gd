class_name FishingRod
extends Node2D

@export var speed: float = 300.0 
@export var water_body: WaterBody = null 
@export var fishes_spawn_pool : Node2D = null

@onready var RodVisualizer : Sprite2D = $RodVisualizer
@onready var ShotReticle : Sprite2D = $ShotReticle
@onready var CatchingMinigame : CatchMinigame = $CatchMinigame

var playing_minigame : bool = false
var hook_thrown : bool = false

func _ready():
	GameManagerScript.game_over.connect(on_minigame_finished)
	GameManagerScript.game_fish_selected.connect(on_fish_selected)

func _process(delta):
	if not hook_thrown:
		# Move reticle
		var input_direction = Vector2.ZERO
		if Input.is_action_pressed("ui_right"):
			input_direction.x += 1
		if Input.is_action_pressed("ui_left"):
			input_direction.x -= 1
		if Input.is_action_pressed("ui_down"):
			input_direction.y += 1
		if Input.is_action_pressed("ui_up"):
			input_direction.y -= 1
		if input_direction != Vector2.ZERO:
			input_direction = input_direction.normalized()
			var new_position = ShotReticle.global_position + input_direction * speed * delta
			if is_inside_water_body(new_position):
				ShotReticle.global_position = new_position
		
		if Input.is_action_just_pressed("ui_accept") and CatchingMinigame:
			hook_thrown = true
			find_closest_fish()
	if playing_minigame:
		if Input.is_action_just_pressed("ui_accept") and CatchingMinigame:
			CatchingMinigame.check_key_press()
		
func is_inside_water_body(point: Vector2) -> bool:
	if water_body == null:
		return true #Should not get here
	return water_body.is_point_inside_polygon(point)

func set_water_body(water_body_node: WaterBody):
	water_body = water_body_node

func find_closest_fish():
	var index = randi()%fishes_spawn_pool.get_child_count()
	var fish_selected = fishes_spawn_pool.get_child(index) as FishBase
	fish_selected.Hunt(ShotReticle.global_position)

func on_fish_selected(difficulty : int):
	playing_minigame = true
	CatchingMinigame.prepare_minigame(ShotReticle.global_position, difficulty)

func on_minigame_finished(minigame_won):
	hook_thrown = false
	playing_minigame = false
