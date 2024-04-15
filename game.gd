extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Musicplayer.stream = AudioStreamOggVorbis.load_from_file("res://ost/LD48_alle_Ebenen.ogg")
	#Musicplayer.play()
	#pass
	var test = []
	print(test.size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.gameState == Globals.STATE_PLAY:
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
		if Input.is_action_just_pressed("ui_accept"):
			$Autobattler.spawn("KNIGHT", 0)
		if Input.is_action_just_pressed("ui_select"):
			var animation = Animation.new()
			var track_index = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(track_index, "Enemy:position:x")
			animation.track_insert_key(track_index, 0.0, 0)
			animation.track_insert_key(track_index, 0.5, 100)
	elif Globals.gameState == Globals.STATE_START:
			if Input.is_action_just_pressed("ui_accept") \
				or Input.is_action_just_pressed("ui_select"):
					start_game()

func start_game():
	$Start/Button.disabled = true
	$Start/AnimationPlayer.play("start_game")
	await $Start/AnimationPlayer.animation_finished
	$Puyo.new_game()
	Globals.gameState = Globals.STATE_PLAY

func _on_button_pressed():
	start_game()

func _on_puyo_game_lost():
	Globals.gameState = Globals.STATE_END

func _on_puyo_spawn_ally(bonus, type):
	$Autobattler.spawn(type, bonus)
