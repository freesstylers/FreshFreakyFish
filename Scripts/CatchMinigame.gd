class_name CatchMinigame
extends Node2D

@export var rotation_speed: float = 0.50  # Degrees per second
@export var key_areas: Array[Array] = []  # Array of key areas
@export var success_threshold: float = deg_to_rad(45.0)
@export var NumRopeSegments = 4

@onready var MinigamePath : Path2D = $MinigamePath
@onready var PlayerIndicator : PathFollow2D = $MinigamePath/PlayerIndicator
@onready var BorderVisualizer : Line2D = $LinePath
@onready var TimeToStartLeft : Label = $TimeToStartLabel
@onready var TimeToStartTimer : Timer = $StartTimer

var timer_count_time = 0
var KeyLinePaths : Array[Line2D]
var next_area_index : int = 0
var next_line_index : int = 0
var current_set_index : int = 0
var playing : bool = false
var minigame_finished : bool = false

func _ready():
	PrepareMiniGameCircle()
	prepare_minigame(Vector2(500,300), [
		[{angle=deg_to_rad(90)}, {angle=deg_to_rad(180)}, {angle=deg_to_rad(270)}],
		[{angle=deg_to_rad(140)}, {angle=deg_to_rad(200)}]
		])

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

func rotate_indicator(delta):
	#Check for missed notes
	var rad = PlayerIndicator.progress_ratio * (2*PI)
	if not minigame_finished and rad - (success_threshold/2) > key_areas[current_set_index][next_area_index].angle:
		hide_key(KeyLinePaths[next_line_index],true)
		#next set of notes
		if next_area_index == 0:
			var next_set = (current_set_index+1) % key_areas.size()
			if next_set != 0:
				show_keynotes(next_set)		
			minigame_finished = true		
	#Rotate
	var rotation_delta = rotation_speed * delta
	if PlayerIndicator.progress_ratio+rotation_delta > 1 and minigame_finished:
		current_set_index = (current_set_index+1) % key_areas.size()	
		#Next set of notes, if 0 then the minigame is finished
		if current_set_index ==0:
			hide_minigame()
		else:
			minigame_finished = false
	PlayerIndicator.progress_ratio += rotation_delta

func check_key_press():
	if Input.is_action_just_pressed("ui_accept"):  # Change to your desired input
		var rad = PlayerIndicator.progress_ratio * (2*PI)
		var min_success_val = key_areas[current_set_index][next_area_index].angle - (success_threshold/2)
		var max_success_val = key_areas[current_set_index][next_area_index].angle + (success_threshold/2)
		if rad > min_success_val and rad < max_success_val:
			hide_key(KeyLinePaths[next_line_index],true)

func hide_key(key_to_hide, success):
	var local_tween = create_tween()
	local_tween.set_parallel(true)
	local_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	local_tween.tween_property(key_to_hide, "scale", Vector2.ZERO, 0.75)
	local_tween.tween_property(key_to_hide, "default_color:a", 0, 0.5)
	next_line_index = next_line_index + 1 
	next_area_index = (next_area_index + 1) % key_areas[current_set_index].size()

func hide_minigame():
	var local_tween = create_tween()
	local_tween.tween_property(self, "scale", Vector2.ZERO, 0.75)

func PrepareMiniGameCircle():
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

func prepare_minigame(global_pos_to_appear : Vector2 , areas_to_place : Array[Array], starting_time : int = 1):
	global_position = global_pos_to_appear
	playing = false
	minigame_finished = false
	PlayerIndicator.progress_ratio = 0
	
	key_areas = areas_to_place
	current_set_index = 0
	next_area_index = 0
	next_line_index = 0
	
	TimeToStartTimer.wait_time = starting_time
	timer_count_time = starting_time
	TimeToStartLeft.text = str(3 as int)
	
	scale = Vector2(0,0)
	var local_tween = create_tween()
	local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	local_tween.tween_property(self, "scale", Vector2(1,1), 0.4)
	local_tween.tween_callback(func():
		show_keynotes(0))
	setup_key_areas()

func show_keynotes(index):
	TimeToStartTimer.start()
	for i in range(key_areas[index].size()):
		var local_tween = create_tween()
		local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		local_tween.set_parallel(true)
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "scale", Vector2(1,1),0.75).set_delay(0.2 * i)
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "default_color:a", 1,0.5).set_delay((0.2 * i)+0.25)

func setup_key_areas():
	#Reset all keypaths 
	for i in range($KeyLinePaths.get_child_count()):
		KeyLinePaths.append($KeyLinePaths.get_child(i))
		KeyLinePaths[i].clear_points()
		KeyLinePaths[i].default_color.a = 0
	
	var currentLineVisualizer : Line2D = null
	var index : int = 0
	for i in range(key_areas.size()):
		for j in range(key_areas[i].size()):
			currentLineVisualizer = KeyLinePaths[index]
			index = index + 1
			#Reset Line2D
			currentLineVisualizer.clear_points()
			for point in range(0,5):
				currentLineVisualizer.add_point(Vector2(0,0))
			#Set 5 vertices to visualize the area
			var mid_angle = key_areas[i][j].angle
			var start_angle = mid_angle-success_threshold/2
			var angle_increment: float = success_threshold / 5
			for point in range(5):
				var angle: float = start_angle + (point * angle_increment)
				var x: float = 100 * cos(angle)
				var y: float = 100 * sin(angle)
				currentLineVisualizer.set_point_position(point,Vector2(x, y))
			currentLineVisualizer.scale = Vector2(0,0)

func start_timer_ended():
	playing = true 
	TimeToStartLeft.visible=false
