extends AudioStreamPlayer

@export var mainmenumusic : AudioStream = null
@export var gamemusic : AudioStream = null 

var tween : Tween = null

func _on_play_pressed():
	tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 1.0)
	tween.tween_callback(func (): 
		tween = create_tween()
		stream = gamemusic
		play()
		tween.tween_property(self, "volume_db", 0, 1.0)
		)

func _on_back_pressed():
	tween = create_tween()
	tween.tween_property(self, "volume_db", -80, 1.0)
	tween.tween_callback(func (): 
		tween = create_tween()
		stream = mainmenumusic
		play()
		tween.tween_property(self, "volume_db", 0, 1.0)
		)
