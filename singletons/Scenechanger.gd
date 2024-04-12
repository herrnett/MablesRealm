extends Node2D

@export var fade: bool
@export var fade_color: Color
@export var fadetime: int
var colorrect = ColorRect.new()
var tween

func change_scene(path):
	var fade_color_translucent = fade_color.clamp(Color(0, 0, 0, 0), Color(1, 1, 1, 0))
	colorrect.size = get_viewport().get_visible_rect().size
	colorrect.color = fade_color_translucent
	add_child(colorrect)
	
	if fade:
		tween = create_tween()
		tween.tween_property(colorrect, "color", fade_color, fadetime)
		await tween.finished
		tween.stop()
	var _err = get_tree().change_scene_to_file(path)
	if fade:
		tween.tween_property(colorrect, "color", fade_color_translucent, fadetime)
		tween.play()
		await tween.finished
		tween.kill()
	
	remove_child(colorrect)
