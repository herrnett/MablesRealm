extends AudioStreamPlayer

## Time in seconds for the fade to happen.
@export var fadetime: int
var maxvolume = volume_db
var tween

func fade_out():
	# tween music volume down to 0
	if tween: 
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", -80, fadetime)
	await tween.finished
	self.stop()

func fade_in():
	if not is_playing():
		# tween music volume to maxvolume
		if tween: 
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "volume_db", maxvolume, fadetime)
		self.play()
