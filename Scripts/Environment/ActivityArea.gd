class_name ActivityArea
extends Node

@export var CurrentActivity : float = 0
@export var ActDelta : float = 50
@export var ActiveArea : bool = true

const MAX_ACTIVITY : float = 100
const MIN_ACTIVITY : float = 0

@onready var AreaVisualizer : Sprite2D = $AreaVisualizer
@onready var AreaTrigger : Area2D = $Area

# Neighboring areas
var above_area : ActivityArea = null
var below_area : ActivityArea = null
var left_area : ActivityArea = null
var right_area : ActivityArea = null

func _ready():
	CurrentActivity = 100

func _process(delta):
	# Calm water? do nothing
	if not ActiveArea or CurrentActivity == 0:
		return
	
	CurrentActivity = clamp(CurrentActivity - (delta * ActDelta), MIN_ACTIVITY, MAX_ACTIVITY)
	var colorValue = CurrentActivity / MAX_ACTIVITY
	AreaVisualizer.modulate = Color(colorValue, colorValue, colorValue, AreaVisualizer.modulate.a)

func AddActivity(additionalActivity: float):
	CurrentActivity = clamp(CurrentActivity + additionalActivity, MIN_ACTIVITY, MAX_ACTIVITY)

func Get_Activity_Level() -> float:
	return CurrentActivity

# Combined setter method for neighboring areas
func set_neighboring_areas(above: ActivityArea = null, below: ActivityArea = null, left: ActivityArea = null, right: ActivityArea = null):
	above_area = above
	below_area = below
	left_area = left
	right_area = right
