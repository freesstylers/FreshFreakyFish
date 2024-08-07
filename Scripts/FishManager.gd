extends Sprite2D

@export var totalNumFish : int = 13

# Esto determina lo picuda que es la campana de probabilidades, cuanto mas cercana a 0 mas picuda
@export var variance : float = 1.2

@onready var newFishSound : AudioStreamPlayer = $NewFishSound
@onready var oldFishSound : AudioStreamPlayer = $OldFishSound
@onready var failedCatchSound : AudioStreamPlayer = $FailedCatchSound
@onready var fishBiteSound : AudioStreamPlayer = $FishBiteSound

var totalFishCaught : int = 0
var distinctFishCaught : int = 0

var fishArray : Array

var actualFish : Fish = null

var colosalCaught : bool = false

func _ready():
	
	GameManagerScript.connect("game_over", _on_won_minigame)
	GameManagerScript.game_start_playing.connect(Fish_Hook_Eaten)	
	
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
	if not colosalCaught:
		for i in totalNumFish:
			if i == 0:
				fishArray[i].Probability = getGaussianProbability(i)
			else:
				fishArray[i].Probability = getGaussianProbability(i) + fishArray[i-1].Probability
		
		if distinctFishCaught > totalNumFish-3:
			fishArray[totalNumFish-1].Probability = 0.1
		else:
			fishArray[totalNumFish-1].Probability = 0.0
			
	else:
		for i in totalNumFish:
			fishArray[i].Probability = 1.0 / totalNumFish
			if i > 0:
				fishArray[i].Probability+=fishArray[i-1].Probability
		

# Ajustamos la campana para que la suma de todas las probabilidades (menos las de coloso) sumen 100%
func normalizeProbabilities():
	var acumProb : float = 0.0
	for i in totalNumFish-1:
		acumProb += fishArray[i].Probability
	
	var resto = 1.0 - acumProb
	
	for i in totalNumFish-1:
		fishArray[i].Probability += resto*fishArray[i].Probability
		
func getFish():
	
	var alreadyCaught : bool = false
	var fishCaught : Fish = null
	
	while alreadyCaught == false:
		var randoNum = randi_range(1, 10000)
		for i in fishArray.size():
			
			var prevProb : float = 0.0
			if i == 0:
				prevProb = 0.0
			else:
				prevProb = fishArray[i-1].Probability
				
			# Lo hacemos de esta manera para que las probabilidades actuen como pesos
			# Y lo multiplicamos por 10000 para que haya precision de hasta dos decimales
			var thisFishProb = fishArray[i].Probability
			if randoNum > prevProb*10000 and randoNum < thisFishProb*10000:
					
				fishCaught = fishArray[i]

				alreadyCaught = true
				break
	
	# Si el Coloso ya puede ser capturado, hacemos el cálculo después por separado
	if fishArray[totalNumFish-1].Probability > 0.0:
		var ran = randi_range(1, 10)
		if ran == 1:
			fishCaught = fishArray[totalNumFish-1]
			
	actualFish = fishCaught
	return fishCaught
	
func _on_won_minigame(won):
	if won:
		texture = actualFish.Sprite
		var showScale : Vector2 = Vector2(3.0, 3.0)
		if actualFish.IsColosal:
			showScale = Vector2(3.0, 3.0)
		var local_tween = create_tween()
		local_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		local_tween.tween_property(self, "scale", showScale, 2.0)
		local_tween.tween_callback(func():
			var local_tween2 = create_tween()
			local_tween2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			local_tween2.tween_property(self, "scale", Vector2(0,0), 2.0)
			)
				
		var i = findFishIndex(actualFish)
		#Si es nuevo, lo marcamos y recalculamos probabilidades
		if fishArray[i].Caught == false:
			distinctFishCaught+=1
			fishArray[i].Caught = true
			if fishArray[i].IsColosal:
				colosalCaught = true
			if !GameManagerScript.save_dict.has(fishArray[i].Name):
				GameManagerScript.save_dict[fishArray[i].Name] = true
				GameManagerScript.save_game()
			recalculateProbabilities()
			newFishSound.play()
		else:
			oldFishSound.play()
	else:
		failedCatchSound.play()
			
func findFishIndex(fish : Fish):
	for i in fishArray.size():
		if fish.Name == fishArray[i].Name:
			return i

func Fish_Hook_Eaten():
	#Random fish 
	var fish = getFish()
	GameManagerScript.game_fish_selected.emit(fish.Difficulty)
	fishBiteSound.play()
