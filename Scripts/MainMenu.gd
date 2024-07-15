extends Control

@onready var ButtonSFX: AudioStreamPlayer = $CanvasLayer/ButtonSFX

@export var FirstButton : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	FirstButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func FreeStylers():
	ButtonSFX.play()
	OS.shell_open("https://freestylers-studio.itch.io/")

func Jam():
	ButtonSFX.play()
	OS.shell_open("https://itch.io/jam/mermelada-jam-3")

func Twitter():
	ButtonSFX.play()
	OS.shell_open("https://twitter.com/FreeStylers_Dev")

func _on_freestylers_pressed():
	FreeStylers()

func _on_jam_pressed():
	Jam()

func _on_twitter_pressed():
	Twitter()

func _on_play_pressed():
	get_node(".").visible = false
	ButtonSFX.play()

func _on_how_to_play_pressed():
	$CanvasLayer/HowToPlay.visible = true

func _on_credits_pressed():
	$CanvasLayer/Credits.visible = true
	ButtonSFX.play()

func _on_LanguageSelector_button_pressed():
	ButtonSFX.play()

func _on_credits_close_pressed():
	$CanvasLayer/Credits.visible = false
	ButtonSFX.play()

func _on_how_to_play_close_pressed():
	$CanvasLayer/HowToPlay.visible = false
	ButtonSFX.play()
