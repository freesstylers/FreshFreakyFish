extends Node


@export var totalNumFish : int = 13

var totalFishCaught : int = 0
var distinctFishCaught : int = 0

var fishDictionary : Dictionary

func _ready():
	for i in totalNumFish:
		var newfish : Fish
		if i == totalNumFish-1:
			newfish = load("res://Resources/Fishes/FishColosal.tres") as Fish
		else:
			newfish = load("res://Resources/Fishes/Fish"+str(i+1)+".tres") as Fish
		newfish.Probability = 0.0
		fishDictionary[newfish.Name] = newfish
		print("Loaded " + newfish.Name)
