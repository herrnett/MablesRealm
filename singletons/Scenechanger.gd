extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var colorrect = $ColorRect


func change_scene(path, fade = false):
	if fade:
		animation_player.play("fade")
		await animation_player.animation_finished
	Globals.gotcurrentplant = false
	var _err = get_tree().change_scene(path)
	Globals.ghost = false
	Globals.ghostdata = []
	if fade: animation_player.play_backwards("fade")
