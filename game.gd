extends Node2D

var fullscreen= false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Ambient.play()

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
	$Start/AudioStreamPlayer2D.play()
	await $Start/AnimationPlayer.animation_finished
	$Puyo.new_game()
	$Autobattler.new_game()
	Musicplayer.fade_in()
	Globals.gameState = Globals.STATE_PLAY

func _on_button_pressed():
	start_game()

func _on_puyo_game_lost():
	Globals.gameState = Globals.STATE_END

func _on_puyo_spawn_ally(bonus, type):
	$Autobattler.spawn(type, bonus)

func _on_autobattler_game_over():
	Globals.gameState = Globals.STATE_GAMEOVER
	$Start/AnimationPlayer.play_backwards("start_game")
	$Start/AudioStreamPlayer2D.play()
	await $Start/AnimationPlayer.animation_finished
	$Start/Button.disabled = false


func _on_next_song_button_pressed():
	Musicplayer.next_song()
	$MenuQuiet/NextSong.size = Vector2i(0,0)


func _on_full_screen_button_pressed():
	if not fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = false


func _on_ptsd_off_pressed():
	if not $Ambient.is_playing():
		$Ambient.play()
	else:
		$Ambient.stop()
