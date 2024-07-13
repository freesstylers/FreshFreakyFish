extends Control

@export var notCaught: Fish
@export var detailedPage: DetailedPage
var button : Button
@export var fishReference : Fish

func _ready():
	button = get_child(0)

func _on_button_pressed():
	if GameManagerScript.save_dict.has(fishReference.Name):
		detailedPage.image.texture = fishReference.Sprite
		detailedPage.fishName.text = tr(fishReference.Name)
		detailedPage.fishDesc.text = tr(fishReference.Description)
	else: 
		detailedPage.image.texture = notCaught.Sprite
		detailedPage.fishName.text = tr(notCaught.Name)
		detailedPage.fishDesc.text = tr(notCaught.Description)

func _on_visibility_changed():
	
	if GameManagerScript.save_dict.has(fishReference.Name):
		button.icon = fishReference.Sprite
	else:
		button.icon = notCaught.Sprite
	pass # Replace with function body.
