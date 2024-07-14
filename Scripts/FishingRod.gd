class_name FishingRod
extends Node2D

@export var speed: float = 300.0 
@export var water_body: WaterBody = null 

@onready var RodVisualizer : Sprite2D = $RodVisualizer
@onready var ShotReticle : Sprite2D = $ShotReticle
@onready var CatchingMinigame : CatchMinigame = $CatchMinigame

var playing_minigame : bool = false

func _process(delta):
	if not playing_minigame:
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
			CatchingMinigame.prepare_minigame(Vector2(300,300), 4)
			playing_minigame = true
	else:
		if Input.is_action_just_pressed("ui_accept") and CatchingMinigame:
			CatchingMinigame.check_key_press()
		
func is_inside_water_body(point: Vector2) -> bool:
	if water_body == null:
		return true #Should not get here
	return water_body.is_point_inside_polygon(point)

func set_water_body(water_body_node: WaterBody):
	water_body = water_body_node

func on_minigame_finished(minigame_won):
	playing_minigame = false
