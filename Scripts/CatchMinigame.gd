class_name CatchMinigame
extends Node2D

@export var rotation_speed: float = 0.50  # Degrees per second
@export var key_areas: Array[Array] = []  # Array of key areas
@export var success_threshold: float = 10.0  # Degrees
@export var NumRopeSegments = 4

@onready var MinigamePath : Path2D = $MinigamePath
@onready var PlayerIndicator : PathFollow2D = $MinigamePath/PlayerIndicator
@onready var BorderVisualizer : Line2D = $LinePath
@onready var TimeToStartLeft : Label = $TimeToStartLabel
@onready var TimeToStartTimer : Timer = $StartTimer

var timer_count_time = 0
var KeyLinePaths : Array[Line2D]
var next_area_index : int = 0
var current_set_index : int = 0
var playing : bool = false

func _ready():
	DrawMiniGameCircle()
	prepare_minigame(Vector2(500,300), [])

func _process(delta):
	if not playing:
		start_playing_countdown()
	else:
		rotate_indicator(delta)
		check_key_press()

func start_playing_countdown():
	if(not TimeToStartTimer.is_stopped()):
		var time = clamp(3 * (TimeToStartTimer.time_left/timer_count_time)+1, 0, 3)
		TimeToStartLeft.text = str(time as int)

func start_timer_ended():
	playing = true 
	TimeToStartLeft.visible=false

func setup_key_areas():
	# Add your key areas setup code here
	pass

func rotate_indicator(delta):
	PlayerIndicator.progress_ratio += rotation_speed * delta

func check_key_press():
	if Input.is_action_just_pressed("ui_accept"):  # Change to your desired input
		#for area in key_areas:
			#if abs(.rotation_degrees - area.rotation_degrees) < success_threshold:
				#randomize_key_areas()
				#return
		print("Missed!")

func prepare_minigame(global_pos_to_appear : Vector2 , areas_to_place : Array[Array], starting_time : int = 1):
	playing = false
	PlayerIndicator.progress_ratio = 0
	next_area_index = 0
	current_set_index = 0
	key_areas = areas_to_place
	
	global_position = global_pos_to_appear
	TimeToStartTimer.wait_time = starting_time
	timer_count_time = starting_time
	TimeToStartLeft.text = str(3 as int)
	scale = Vector2(0,0)
	var local_tween = create_tween()
	local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	local_tween.tween_property(self, "scale", Vector2(1,1), 0.4)
	local_tween.tween_callback(TimeToStartTimer.start)

func DrawMiniGameCircle():
	#Reset all keypaths 
	for i in range($KeyLinePaths.get_child_count()):
		KeyLinePaths.append($KeyLinePaths.get_child(i))
		KeyLinePaths[i].clear_points()
	#Reset Line2D
	BorderVisualizer.clear_points()
	for i in range(0,NumRopeSegments+1):
		BorderVisualizer.add_point(Vector2(0,0))
	var angle_increment: float = (2 * PI) / NumRopeSegments 
	for i in range(NumRopeSegments+1):
		var angle: float = i * angle_increment
		var x: float = 100 * cos(angle)
		var y: float = 100 * sin(angle)
		BorderVisualizer.set_point_position(i,Vector2(x, y))
