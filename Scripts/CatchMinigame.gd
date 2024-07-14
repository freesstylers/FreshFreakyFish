class_name CatchMinigame
extends Node2D

@export var rotation_speed: float = 0.10  # Radians per second
@export var key_areas: Array[Array] = []  # Notes each time the minigame is played
@export var note_success_threshold: float = deg_to_rad(45.0) #Size of the default note
@export var note_fail_threshold: float = deg_to_rad(25.0) #Size of the default note

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

#LEVEL 1: Facil 1ronda /1 nota grande
#LEVEL 2: 2 rondas un poco más pequeña 1 nota
#Level 3: 3 rondas 2 notas cada una 
#Level 4: 5 rondas 2 notas cada una pequeñas rápido 

var ROTATIONVELOCITIES : Array[float] = [0.55,0.6,0.65,0.75, 0.6]
var NUMSETSPERLEVEL : Array[int] = [1,2,10,5, 1]

#LEVEL 1 LEVELS
var LEVEL1SETS : Array[Array] = [
	[{angle=deg_to_rad(87), rad_width = deg_to_rad(66)} ],
	[{angle=deg_to_rad(100), rad_width = deg_to_rad(71)} ],
	[{angle=deg_to_rad(110), rad_width = deg_to_rad(60)} ],
	[{angle=deg_to_rad(150), rad_width = deg_to_rad(62)} ],
	[{angle=deg_to_rad(180), rad_width = deg_to_rad(71)} ],
	[{angle=deg_to_rad(200), rad_width = deg_to_rad(60)} ],
	[{angle=deg_to_rad(210), rad_width = deg_to_rad(65)} ],
	[{angle=deg_to_rad(250), rad_width = deg_to_rad(50)} ],
	[{angle=deg_to_rad(280), rad_width = deg_to_rad(58)} ],
	[{angle=deg_to_rad(300), rad_width = deg_to_rad(67)} ],
	[{angle=deg_to_rad(320), rad_width = deg_to_rad(49)} ],
	]

var LEVEL2SETS : Array[Array] = [
	[{angle=deg_to_rad(93), rad_width = deg_to_rad(57)} ],
	[{angle=deg_to_rad(111), rad_width = deg_to_rad(66)} ],
	[{angle=deg_to_rad(109), rad_width = deg_to_rad(55)} ],
	[{angle=deg_to_rad(152), rad_width = deg_to_rad(49)} ],
	[{angle=deg_to_rad(183), rad_width = deg_to_rad(65)} ],
	[{angle=deg_to_rad(205), rad_width = deg_to_rad(41)} ],
	[{angle=deg_to_rad(219), rad_width = deg_to_rad(55)} ],
	[{angle=deg_to_rad(243), rad_width = deg_to_rad(40)} ],
	[{angle=deg_to_rad(289), rad_width = deg_to_rad(49)} ],
	[{angle=deg_to_rad(306), rad_width = deg_to_rad(58)} ],
	[{angle=deg_to_rad(333), rad_width = deg_to_rad(44)} ],
	]
	
var LEVEL3SETS : Array[Array] = [
	[{angle=deg_to_rad(143), rad_width = deg_to_rad(55)} ],
	[{angle=deg_to_rad(120), rad_width = deg_to_rad(40)} ],
	[{angle=deg_to_rad(169), rad_width = deg_to_rad(50)} ],
	[{angle=deg_to_rad(250), rad_width = deg_to_rad(40)} ],
	[{angle=deg_to_rad(307), rad_width = deg_to_rad(47)} ],
	[{angle=deg_to_rad(145), rad_width = deg_to_rad(47)}, {angle=deg_to_rad(210), rad_width = deg_to_rad(40)}],
	[{angle=deg_to_rad(138), rad_width = deg_to_rad(52)}, {angle=deg_to_rad(298), rad_width = deg_to_rad(47)}], 
	[{angle=deg_to_rad(143), rad_width = deg_to_rad(55)}, {angle=deg_to_rad(277), rad_width = deg_to_rad(39)}],
	[{angle=deg_to_rad(202), rad_width = deg_to_rad(57)}, {angle=deg_to_rad(274), rad_width = deg_to_rad(44)} ],
	[{angle=deg_to_rad(222), rad_width = deg_to_rad(43)}, {angle=deg_to_rad(301), rad_width = deg_to_rad(49)} ],
	]
	
var LEVEL4SETS : Array[Array] = [
	[{angle=deg_to_rad(320), rad_width = deg_to_rad(35)}],
	[{angle=deg_to_rad(110), rad_width = deg_to_rad(35)}, {angle=deg_to_rad(197), rad_width = deg_to_rad(30)} ],
	[{angle=deg_to_rad(140), rad_width = deg_to_rad(48)}, {angle=deg_to_rad(244), rad_width = deg_to_rad(65)} ],
	[{angle=deg_to_rad(155), rad_width = deg_to_rad(32)}, {angle=deg_to_rad(305), rad_width = deg_to_rad(47)} ],
	[{angle=deg_to_rad(168), rad_width = deg_to_rad(30)},{angle=deg_to_rad(288), rad_width = deg_to_rad(36)} ],
	[{angle=deg_to_rad(190), rad_width = deg_to_rad(35)}, {angle=deg_to_rad(227), rad_width = deg_to_rad(30)} ],
	[{angle=deg_to_rad(190), rad_width = deg_to_rad(38)}, {angle=deg_to_rad(250), rad_width = deg_to_rad(50)} ], 
	[{angle=deg_to_rad(120), rad_width = deg_to_rad(34)}, {angle=deg_to_rad(200), rad_width = deg_to_rad(30)},{angle=deg_to_rad(290), rad_width = deg_to_rad(31)} ],
	[{angle=deg_to_rad(190), rad_width = deg_to_rad(34)}, {angle=deg_to_rad(240), rad_width = deg_to_rad(30)},{angle=deg_to_rad(310), rad_width = deg_to_rad(31)} ],
	]
	
var TESTING_SET : Array[Array] = [
	[{angle=deg_to_rad(300), rad_width = deg_to_rad(50)} ]
	]

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
	
	scale = Vector2.ZERO	
	prepare_minigame(Vector2(400,400), 4)

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
			#if next_set != 0:
				#show_keynotes(next_set)		
	#Rotate
	var rotation_delta = rotation_speed * delta
	if PlayerIndicator.progress_ratio+rotation_delta > 1 and note_set_finished: 
		current_set_index = (current_set_index+1) % key_areas.size()	
		#Next set of notes, if 0 the minigame is finished
		if current_set_index == 0:
			hide_minigame(true)
		else:
			note_set_finished = false
			show_keynotes(current_set_index)	
	PlayerIndicator.progress_ratio += rotation_delta

func check_key_press():
	#Where is the player right now and where are the limits of the next note
	var rad = PlayerIndicator.progress_ratio * (2*PI)
	var min_success_val = key_areas[current_set_index][next_note_index].angle - (note_success_threshold/2)
	var max_success_val = key_areas[current_set_index][next_note_index].angle + (note_success_threshold/2)
	if not minigame_finished  and Input.is_action_just_pressed("ui_accept"):
		if rad > min_success_val and rad < max_success_val:
			KeyLinePaths[next_line_index].width = NoteHitableWidth
			#Note Hit
			hide_key(KeyLinePaths[next_line_index],true)
			#next set of notes
			if next_note_index == 0:
				note_set_finished = true		
				var next_set = (current_set_index+1) % key_areas.size()
				if next_set != 0:
					pass
					#show_keynotes(next_set)		
				else:
					hide_minigame(true)
		elif rad > min_success_val - note_fail_threshold and rad < min_success_val:
			hide_key(KeyLinePaths[next_line_index],false)
			minigame_finished = true
			hide_minigame(false)
			#next set of notes
			if next_note_index == 0:
				note_set_finished = true	

func prepare_minigame(global_pos_to_appear,level, starting_time = 1):
	global_position = global_pos_to_appear
	playing = false
	note_set_finished = false
	minigame_finished = false
	PlayerIndicator.progress_ratio = 0
	
	#Notes related, set, line2d index...
	var sets_source : Array[Array]
	match level:
		#Level 1, only one note big, slow and easy
		1:
			sets_source = LEVEL1SETS
		2:
			sets_source = LEVEL2SETS
		3:
			sets_source = LEVEL3SETS
		4:
			sets_source = LEVEL4SETS
		5:
			sets_source = TESTING_SET

	rotation_speed = ROTATIONVELOCITIES[level-1]
	for set_index in range(NUMSETSPERLEVEL[level-1]):
		key_areas.append(sets_source[randi()%sets_source.size()])
	current_set_index = 0
	next_note_index = 0
	next_line_index = 0
	note_success_threshold = key_areas[0][0].rad_width
	
	#Time left till the minigame starts
	TimeToStartTimer.wait_time = starting_time
	timer_count_time = starting_time
	TimeToStartLeft.text = str(3 as int)
	TimeToStartLeft.visible = true
	
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
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "scale", Vector2(1,1),0.5).set_delay(0.2 * i)
		local_tween.tween_property(KeyLinePaths[next_line_index + i], "default_color:a", 1,0.35).set_delay((0.2 * i)+0.25)

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
	playing = false
	if(minigame_won):
		var local_tween = create_tween()
		local_tween.tween_property(self, "scale", Vector2.ZERO, 0.75)
		local_tween.tween_callback(func():
			GameManagerScript.game_over.emit(minigame_won))
	else:
		var local_tween = create_tween()   
		local_tween.tween_property(self, "scale", Vector2.ZERO, 0.75)
		local_tween.tween_callback(func():
			GameManagerScript.game_over.emit(minigame_won))		

func start_timer_ended():
	playing = true 
	TimeToStartLeft.visible=false
