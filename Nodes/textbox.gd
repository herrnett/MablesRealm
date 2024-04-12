extends Sprite2D

@export var textoffset_x_left = 0
@export var textoffset_x_right = 0
@export var textoffset_y_top = 0
@export var textoffset_y_bottom = 0
@export var textspeed: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var spritedimensions = self.get_rect().size
	$RichTextLabel.size.x = spritedimensions.x - textoffset_x_left - textoffset_x_right
	$RichTextLabel.size.y = spritedimensions.y - textoffset_y_top - textoffset_y_bottom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
