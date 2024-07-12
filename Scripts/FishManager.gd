extends Node

@export var totalNumFish : int = 13

# Esto determina lo picuda que es la campana de probabilidades, cuanto mas cercana a 0 mas picuda
@export var variance : float = 1.2

var totalFishCaught : int = 0
var distinctFishCaught : int = 0

var fishArray : Array

func _ready():
	for i in totalNumFish:
		var newfish : Fish
		if i == totalNumFish-1:
			newfish = load("res://Resources/Fishes/FishColosal.tres") as Fish
		else:
			newfish = load("res://Resources/Fishes/Fish"+str(i+1)+".tres") as Fish
		fishArray.push_back(newfish)
	recalculateProbabilities()
		
func getGaussianProbability(num):
	var prob : float = 0.0
	var first : float = 1/(sqrt(2*PI*variance))
	var eulerNumber = 2.71828
	var exponent = -(pow(num-distinctFishCaught, 2)/(2*variance))
	var sec : float = pow(eulerNumber, exponent) 
	prob = first*sec
	return prob
	
func recalculateProbabilities():
	for i in totalNumFish:
		fishArray[i].Probability = getGaussianProbability(i)
		print(str(fishArray[i].Probability))
	
	if distinctFishCaught > totalNumFish-3:
		fishArray[totalNumFish-1].Probability = 0.1
	else:
		fishArray[totalNumFish-1].Probability = 0.0
		
