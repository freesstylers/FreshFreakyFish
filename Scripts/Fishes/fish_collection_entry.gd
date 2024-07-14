extends Control

@export var notCaught: Fish
@export var detailedPage: DetailedPage
@export var button : Button
@export var fishReference : Fish

func _on_button_pressed():
	if GameManagerScript.save_dict.has(fishReference.Name):
		detailedPage.image.texture = fishReference.Sprite
		detailedPage.fishName.text = "[center]" + tr(fishReference.Name) + "[/center]"
		detailedPage.fishDesc.text = "[center]" + tr(fishReference.Description) + "[/center]"
	else: 
		detailedPage.image.texture = notCaught.Sprite
		detailedPage.fishName.text = "[center]" + tr(notCaught.Name) + "[/center]"
		detailedPage.fishDesc.text = "[center]" + tr(notCaught.Description) + "[/center]"

func _on_visibility_changed():
	
	if GameManagerScript.save_dict.has(fishReference.Name):
		button.icon = fishReference.Sprite
	else:
		button.icon = notCaught.Sprite
	pass # Replace with function body.
