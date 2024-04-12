extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Musicplayer.stream = AudioStreamOggVorbis.load_from_file("res://ost/LD48_alle_Ebenen.ogg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Scenechanger.change_scene("res://testscene.tscn")
	if Input.is_action_just_pressed("ui_select"):
		Musicplayer.fade_in()
