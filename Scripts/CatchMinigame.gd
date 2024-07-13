class_name CatchMinigame
extends Node2D

@export var rotation_speed: float = 0.30  # Radians per second
@export var key_areas: Array[Array] = []  # Notes each time the minigame is played
@export var note_success_threshold: float = deg_to_rad(45.0) #Size of the default note

@onready var PlayerIndicator : PathFollow2D = $MinigamePath/PlayerIndicator
@onready var CirclePathVisualizer : Line2D = $LinePath
@onready var TimeToStartLeft : Label = $TimeToStartLabel
@onready var TimeToStartTimer : Timer = $StartTimer

var timer_count_time = 0
var KeyLinePaths : Array[Line2D]
var next_note_index : int = 0
var next_line_index : int = 0
var current_set_index : int = 0
var playing : bool = false
var note_set_finished : bool = false
var minigame_finished : bool = false

const VerticesCirclePath = 20
const VerticesPerNote = 5
const NoteDefaultWidth = 15
const NoteHitableWidth = 20

func _ready():
	#Reset Line2D and create a dircle
	CirclePathVisualizer.clear_points()
	for i in range(0,VerticesCirclePath+1):
		CirclePathVisualizer.add_point(Vector2(0,0))
	var angle_increment: float = (2 * PI) / VerticesCirclePath 
	for i in range(VerticesCirclePath+1):
		var angle: float = i * angle_increment
		var x: float = 100 * cos(angle)
		var y: float = 100 * sin(angle)
		CirclePathVisualizer.set_point_position(i,Vector2(x, y))
		
	#Reset paths that are used to represent notes 
	for i in range($KeyLinePaths.get_child_count()):
		KeyLinePaths.append($KeyLinePaths.get_child(i))
		KeyLinePaths[i].clear_points()
		
	prepare_minigame(Vector2(500,300), [
		[{angle=deg_to_rad(90), rad_width = deg_to_rad(25)}, {angle=deg_to_rad(180), rad_width = deg_to_rad(45)}, {angle=deg_to_rad(270), rad_width = deg_to_rad(75)}],
		[{angle=deg_to_rad(140), rad_width = deg_to_rad(90)}, {angle=deg_to_rad(200), rad_width = deg_to_rad(10)}]
		])

func _process(delta):
	#Display time left to start the minigame
	if not playing:
		if(not TimeToStartTimer.is_stopped()):
			var time = clamp(3 * (TimeToStartTimer.time_left/timer_count_time)+1, 0, 3)
			TimeToStartLeft.text = str(time as int)
	else:
		rotate_indicator(delta)
		check_key_press()

func rotate_indicator(delta):
	#Check for missed notes
	var player_radians = PlayerIndicator.progress_ratio * (2*PI)
	if not minigame_finished and not note_set_finished and player_radians - (note_success_threshold/2) > key_areas[current_set_index][next_note_index].angle:
		hide_key(KeyLinePaths[next_line_index],false)
		minigame_finished = true
		hide_minigame(false)
		#next set of notes
		if next_note_index == 0:
			note_set_finished = true		
			var next_set = (current_set_index+1) % key_areas.size()
			if next_set != 0:
				show_keynotes(next_set)		
	#Rotate
	var rotation_delta = rotation_speed * delta
	if PlayerIndicator.progress_ratio+rotation_delta > 1 and note_set_finished: 
		current_set_index = (current_set_index+1) % key_areas.size()	
		#Next set of notes, if 0 the minigame is finished
		if current_set_index == 0:
			hide_minigame(true)
		else:
			note_set_finished = false
	PlayerIndicator.progress_ratio += rotation_delta

func check_key_press():
	#Where is the player right now and where are the limits of the next note
	var rad = PlayerIndicator.progress_ratio * (2*PI)
	var min_success_val = key_areas[current_set_index][next_note_index].angle - (note_success_threshold/2)
	var max_success_val = key_areas[current_set_index][next_note_index].angle + (note_success_threshold/2)
	if not minigame_finished and rad > min_success_val and rad < max_success_val:
		KeyLinePaths[next_line_index].width = NoteHitableWidth
		#Note Hit
		if Input.is_action_just_pressed("ui_accept"):
			hide_key(KeyLinePaths[next_line_index],true)
			#next set of notes
			if next_note_index == 0:
				note_set_finished = true		
				var next_set = (current_set_index+1) % key_areas.size()
				if next_set != 0:
					show_keynotes(next_set)		
				else:
					hide_minigame(true)

func prepare_minigame(global_pos_to_appear : Vector2 , areas_to_place : Array[Array], starting_time : int = 1):
	global_position = global_pos_to_appear
	playing = false
	note_set_finished = false
	minigame_finished = false
	PlayerIndicator.progress_ratio = 0
	
	#Notes related, set, line2d index...
	key_areas = areas_to_place
	current_set_index = 0
	next_note_index = 0
	next_line_index = 0
	note_success_threshold = key_areas[0][0].rad_width
	
	#Time left till the minigame starts
	TimeToStartTimer.wait_time = starting_time
	timer_count_time = starting_time
	TimeToStartLeft.text = str(3 as int)
	
	#Show myself
	scale = Vector2(0,0)
	var local_tween = create_tween()
	local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	local_tween.tween_property(self, "scale", Vector2(1,1), 0.4)
	local_tween.tween_callback(func():
		show_keynotes(0))
		
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
			for point in range(0,VerticesPerNote+1):
				currentLineVisualizer.add_point(Vector2(0,0))
			#Set vertices to visualize the Note
			var mid_angle = key_areas[i][j].angle
			note_success_threshold = key_areas[i][j].rad_width
			var start_angle = mid_angle-(note_success_threshold/2)
			var angle_increment: float = note_success_threshold / VerticesPerNote
			for point in range(VerticesPerNote+1):
				var angle: float = start_angle + (point * angle_increment)
				var x: float = 100 * cos(angle)
				var y: float = 100 * sin(angle)
				currentLineVisualizer.set_point_position(point,Vector2(x, y))
			currentLineVisualizer.width = NoteDefaultWidth
			currentLineVisualizer.default_color = Color.BLUE
			currentLineVisualizer.scale = Vector2(0,0)
	note_success_threshold = key_areas[0][0].rad_width

func show_keynotes(index):
	TimeToStartTimer.start()
	note_success_threshold = key_areas[index][0].rad_width
	for i in range(key_areas[index].size()):
		var local_tween = create_tween()
		local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		local_tween.set_parallel(true)
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "scale", Vector2(1,1),0.75).set_delay(0.2 * i)
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "default_color:a", 1,0.5).set_delay((0.2 * i)+0.25)

func hide_key(key_to_hide, success):
	var local_tween = create_tween()
	local_tween.set_parallel(true)
	local_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	local_tween.tween_property(key_to_hide, "scale", Vector2.ZERO, 0.75)
	local_tween.tween_property(key_to_hide, "default_color:a", 0, 0.5)
	#Next Line2D to check for notes
	next_line_index = next_line_index + 1 
	#Next Note to hit, if 0 the current set is finished
	next_note_index = (next_note_index + 1) % key_areas[current_set_index].size()
	note_success_threshold = key_areas[current_set_index][next_note_index].rad_width
	if success:
		key_to_hide.default_color = Color.GREEN
	else:
		key_to_hide.default_color = Color.RED

func hide_minigame(minigame_won):
	if(minigame_won):
		var local_tween = create_tween()
		local_tween.tween_property(self, "scale", Vector2.ZERO, 0.75)
	else:
		var local_tween = create_tween()
		local_tween.tween_property(self, "scale", Vector2.ZERO, 0.75)

func start_timer_ended():
	playing = true 
	TimeToStartLeft.visible=false
