extends AnimatedSprite2D

signal died

const type := "ALLY"
const hspeed : int = 3
const vspeed : float = 0.5
var spawn_pos
var variance : int = 0
var return_home = false

const spawn_sounds = ["res://sfx/Spawn_Knight_1.ogg", \
					"res://sfx/Spawn_Knight_2.ogg", \
					"res://sfx/Spawn_Knight_3.ogg", \
					"res://sfx/Spawn_Knight_4.ogg", \
					"res://sfx/Spawn_Knight_5.ogg", \
					"res://sfx/Spawn_Knight_6.ogg", \
					"res://sfx/Spawn_Knight_7.ogg"]

var current_hp : int = 3
var max_hp: int = 3
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_pos = self.position
	variance = randi_range(0,100)
	get_parent().connect("return_home", _on_return_home)
	play_spawn_sound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_hp > 0:
		if not return_home and get_parent().game_state == get_parent().STATE_PLAY:
			if target:
				if target.position.y - variance > self.position.y: #enemy below
					self.position.y += vspeed*delta*100
					$AnimationPlayer.play("walk")
				elif target.position.y + variance < self.position.y: #enemy above
					self.position.y -= vspeed*delta*100
					$AnimationPlayer.play("walk")
				else:
					attack()				
			if not target:
				self.position.x += hspeed*delta*100
				$AnimationPlayer.play("walk")
		else:
			self.scale.x = -1
			if self.position.x > spawn_pos.x:
				self.position.x -= hspeed*delta*100
				$AnimationPlayer.play("walk")
			else: 
				$AnimationPlayer.play("idle")
				return_home = false
	else:
		emit_signal("died")
		queue_free()

func attack():
	if not $AnimationPlayer.current_animation == "atk" or not $AnimationPlayer.is_playing():
		print(target.position)
		print(self.position)
		$AnimationPlayer.play("atk")
		await $AnimationPlayer.animation_finished
		target.hurt()

func hurt():
	current_hp -= 1
	

func play_spawn_sound():
	var rnd = spawn_sounds.pick_random()
	$AudioStreamPlayer.stream = load(rnd)
	$AudioStreamPlayer.play()

func _on_vision_area_entered(area):
	var parent = area.get_parent()
	if not target and parent.type == "ENEMY":
		target = parent
		parent.connect("died", _on_target_died)

func _on_target_died():
	target = false
	$Vision.monitoring = false
	await get_tree().create_timer(0.5).timeout
	$Vision.monitoring = true

func _on_return_home():
	return_home = true
