extends Node

class_name GameManager 

const FILE_NAME = "user://game-data.json"

#Globals

###################CONSTANTS###################
var RNG = RandomNumberGenerator.new()


#Signals
#signal game_init_everything()
#signal game_start_playing()
#signal game_over(playerDead : bool)

#End Globals


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var save_dict = {}

func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	#JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(save_dict)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
		
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json = save_game.get_as_text()
	
	save_dict = JSON.parse_string(json)
