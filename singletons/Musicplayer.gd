extends AudioStreamPlayer

const songs = ["res://ost/LD55_Theme_1.ogg", \
			"res://ost/LD55_Theme_2.ogg", \
			"res://ost/LD55_Theme_3.ogg"]
var i = 0

## Time in seconds for the fade to happen.
@export var fadetime: int
var maxvolume = -12
var tween

func next_song():
	# tween music volume down to 0
	if tween: 
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume_db", -80, fadetime/2)
	await tween.finished
	self.stop()
	
	i += 1
	i %= 3
	self.stream = load(songs[i])
	
	if not is_playing():
		# tween music volume to maxvolume
		if tween: 
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "volume_db", maxvolume, fadetime)
		self.play()

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
