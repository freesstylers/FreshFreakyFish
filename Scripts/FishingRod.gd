class_name FishingRod
extends Node2D

@export var speed: float = 300.0 
@export var water_body: WaterBody = null 
@export var fishes_spawn_pool : Node2D = null

@onready var RodVisualizer : Sprite2D = $RodVisualizer
@onready var ShotReticle : Sprite2D = $ShotReticle
@onready var ShotReticle2 : Sprite2D = $ShotReticle2
@onready var CatchingMinigame : CatchMinigame = $CatchMinigame
@onready var Seduce_fished_timer : Timer = $Call_Fished_For_Hunt_Timer
@onready var WhiteCircle1 : Sprite2D = $WaterCircle
@onready var WhiteCircle2 : Sprite2D = $WaterCircle2
@onready var WhiteCircle3 : Sprite2D = $WaterCircle3

@onready var floatLandSound : AudioStreamPlayer = $FloatLandSound

var playing_minigame : bool = false
var hook_thrown : bool = false
var on_play_scene : bool = false
var scare_fish_distance : float = 75
var seduce_fish_for_hunt_distance : float = 350

func _ready():
	WhiteCircle1.scale = Vector2.ZERO
	WhiteCircle2.scale = Vector2.ZERO
	WhiteCircle3.scale = Vector2.ZERO
	
	GameManagerScript.game_over.connect(on_minigame_finished)
	GameManagerScript.game_fish_selected.connect(on_fish_selected)
	GameManagerScript.go_to_play_scene.connect(on_go_to_play_scene)
	GameManagerScript.go_back_to_menu.connect(on_go_to_menu)

func _process(delta):
	if not on_play_scene:
		return
	
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
				ShotReticle2.global_position = new_position
		
		if Input.is_action_just_pressed("Pescar") and CatchingMinigame:
			throw_hook()
			floatLandSound.play()
	else:
		if not playing_minigame and hook_thrown and Input.is_action_just_pressed("Pescar"):
			recover_hook()
			
	#Hit notes
	if playing_minigame:
		if Input.is_action_just_pressed("Pescar") and CatchingMinigame:
			CatchingMinigame.check_key_press()
		
func is_inside_water_body(point: Vector2) -> bool:
	if water_body == null:
		return true #Should not get here
	return water_body.is_point_inside_polygon(point)

func set_water_body(water_body_node: WaterBody):
	water_body = water_body_node

func throw_hook():
	ShotReticle2.visible = true
	Seduce_fished_timer.start()
	hook_thrown = true
	var fish_count = fishes_spawn_pool.get_child_count()
	for fish_index in range(fish_count):
		var current_fish = fishes_spawn_pool.get_child(fish_index)
		if (current_fish.global_position - ShotReticle.global_position).length() < scare_fish_distance:
			var dest_pos = water_body.get_random_position_inside_polygon()
			while (dest_pos - ShotReticle.global_position).length() < scare_fish_distance:
				dest_pos = water_body.get_random_position_inside_polygon()
			(current_fish as FishBase).Get_Scared(dest_pos)
	
	WhiteCircle1.global_position = ShotReticle.global_position
	WhiteCircle2.global_position = ShotReticle.global_position
	WhiteCircle3.global_position = ShotReticle.global_position	
	var anim_duration = 2.5
	var end_scale = 0.4
	var local_tween = create_tween()
	local_tween.set_parallel(true)
	local_tween.tween_property(WhiteCircle1, "modulate:a", 0, anim_duration)
	local_tween.tween_property(WhiteCircle1, "scale", Vector2(end_scale,end_scale), anim_duration)
	local_tween.tween_property(WhiteCircle2, "modulate:a", 0, anim_duration).set_delay(0.5)
	local_tween.tween_property(WhiteCircle2, "scale", Vector2(end_scale,end_scale), anim_duration).set_delay(0.5)
	local_tween.tween_property(WhiteCircle3, "modulate:a", 0, anim_duration).set_delay(1.2)
	local_tween.tween_property(WhiteCircle3, "scale", Vector2(end_scale,end_scale), anim_duration).set_delay(1.2)
	local_tween.chain().tween_callback(func():
		WhiteCircle1.scale = Vector2.ZERO
		WhiteCircle2.scale = Vector2.ZERO
		WhiteCircle3.scale = Vector2.ZERO	
		WhiteCircle1.modulate.a = 1
		WhiteCircle2.modulate.a = 1
		WhiteCircle3.modulate.a = 1
		)

func recover_hook():
	hook_thrown = false
	Seduce_fished_timer.stop()
	ShotReticle2.visible = false
	GameManagerScript.hook_recovered.emit()

func on_call_fished_for_hunt_timer_ended():
	var fish_count = fishes_spawn_pool.get_child_count()
	for fish_index in range(fish_count):
		var current_fish = fishes_spawn_pool.get_child(fish_index)
		if (current_fish.global_position - ShotReticle.global_position).length() < seduce_fish_for_hunt_distance:
			(current_fish as FishBase).Hunt(ShotReticle.global_position)

func on_fish_selected(difficulty : int):
	playing_minigame = true
	Seduce_fished_timer.stop()
	CatchingMinigame.prepare_minigame(ShotReticle.global_position, difficulty)

func on_minigame_finished(minigame_won):
	hook_thrown = false
	playing_minigame = false
	ShotReticle2.visible = false

func on_go_to_menu():
	on_play_scene = false
	if hook_thrown:
		recover_hook()
	
func on_go_to_play_scene():
	on_play_scene = true
