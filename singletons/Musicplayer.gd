extends Node

func fade_out():
	# tween music volume down to 0
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -12, 1)

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -12, 1)
