extends Camera2D

@export var mainpos : Node2D = null
@export var gamepos : Node2D = null
@export var MainMenu: Node = null

var posToMoveTo : Vector2 = Vector2(0,0)

func _ready():
	transform = mainpos.transform
	posToMoveTo = mainpos.position

func _on_play_pressed():
	posToMoveTo = gamepos.position
	GameManagerScript.go_to_play_scene.emit()
	
func _process(delta):
	position = lerp(position, posToMoveTo, 0.05)

func _on_back_pressed():
	MainMenu.visible = true
	posToMoveTo = mainpos.position
	GameManagerScript.go_back_to_menu.emit()
