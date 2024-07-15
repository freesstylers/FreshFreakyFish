extends Camera2D

@export var mainpos : Node2D = null
@export var gamepos : Node2D = null
@export var MainMenu: Node = null

@export var RemoveFocusNode: Control = null

var posToMoveTo : Vector2 = Vector2(0,0)

func _ready():
	transform = mainpos.transform
	posToMoveTo = mainpos.position

func _on_play_pressed():
	posToMoveTo = gamepos.position
	GameManagerScript.go_to_play_scene.emit()
	RemoveFocusNode.grab_focus()
	
func _process(delta):
	position = lerp(position, posToMoveTo, 0.05)

@export var Book : Node = null

func _input(event):
	if event.is_action_pressed("Back"):
		if posToMoveTo == gamepos.position and not Book.get_child(0).get_child(0).visible:
			_on_back_pressed()
	if event.is_action_pressed("Book"):
		if posToMoveTo == gamepos.position:
			Book._on_button_pressed()

func _on_back_pressed():
	MainMenu.visible = true
	posToMoveTo = mainpos.position
	GameManagerScript.go_back_to_menu.emit()
