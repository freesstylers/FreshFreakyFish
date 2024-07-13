class_name DetailedPage extends Panel

var image : TextureRect
var fishName : RichTextLabel
var fishDesc : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	image = get_child(0)
	fishName = get_child(1)
	fishDesc = get_child(2)
	pass # Replace with function body.
