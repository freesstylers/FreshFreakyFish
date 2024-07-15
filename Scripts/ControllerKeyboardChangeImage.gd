extends TextureRect

@export var ImageKeyboard: Texture = null
@export var ImageController: Texture = null

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouse:
		texture = ImageKeyboard
	if event is InputEventJoypadButton:
		texture = ImageController
#	if event is InputEventKey and event.pressed:
#		texture = ImageKeyboard
