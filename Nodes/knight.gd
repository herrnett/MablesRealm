extends AnimatedSprite2D

signal died

const type := "ALLY"
var subtype
const hspeed : int = 3
const vspeed : float = 0.5
var spawn_pos
var variance : int = 0
var return_home = false

const spawn_sounds_knight = ["res://sfx/Spawn_Knight_1.ogg", \
					"res://sfx/Spawn_Knight_2.ogg", \
					"res://sfx/Spawn_Knight_3.ogg", \
					"res://sfx/Spawn_Knight_4.ogg", \
					"res://sfx/Spawn_Knight_5.ogg", \
					"res://sfx/Spawn_Knight_6.ogg", \
					"res://sfx/Spawn_Knight_7.ogg"]

const spawn_sounds_healer = ["res://sfx/Spawn_Healer_1.ogg", \
					"res://sfx/Spawn_Healer_2.ogg", \
					"res://sfx/Spawn_Healer_3.ogg", \
					"res://sfx/Spawn_Healer_4.ogg", \
					"res://sfx/Spawn_Healer_5.ogg", \
					"res://sfx/Spawn_Healer_6.ogg"]

const spawn_sounds_archer = ["res://sfx/Spawn_Archer_1.ogg", \
					"res://sfx/Spawn_Archer_2.ogg", \
					"res://sfx/Spawn_Archer_3.ogg", \
					"res://sfx/Spawn_Archer_4.ogg", \
					"res://sfx/Spawn_Archer_5.ogg"]


const spawn_sounds_wizard = ["res://sfx/Spawn_Wizard_1.ogg", \
					"res://sfx/Spawn_Wizard_2.ogg", \
					"res://sfx/Spawn_Wizard_3.ogg", \
					"res://sfx/Spawn_Wizard_4.ogg", \
					"res://sfx/Spawn_Wizard_5.ogg", \
					"res://sfx/Spawn_Wizard_6.ogg", \
					"res://sfx/Spawn_Wizard_7.ogg", \
					"res://sfx/Spawn_Wizard_8.ogg"]

const spawn_sounds_jester = ["res://sfx/honk_1.ogg", \
					"res://sfx/honk_2.ogg", \
					"res://sfx/honk_3.ogg", \
					"res://sfx/honk_4.ogg"]

const arrow_sounds = ["res://sfx/Arrow_1.ogg", "res://sfx/Arrow_2.ogg", "res://sfx/Arrow_3.ogg", "res://sfx/Arrow_4.ogg"]
const cast_sounds = ["res://sfx/Cast_1.mp3", "res://sfx/Cast_2.mp3", "res://sfx/Cast_3.mp3"]

var current_hp : int = 3
var max_hp: int = 3
var target

var atksound

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_pos = self.position
	variance = randi_range(0,100)
	get_parent().connect("return_home", _on_return_home)
	get_parent().connect("game_over", _on_game_over)
	play_spawn_sound()
	
	if subtype == "ARCHER":
		atksound = arrow_sounds.pick_random()
		$Atksound.stream = load(atksound)
		$Atksound.volume_db = -12
	elif subtype == "WIZARD":
		atksound = cast_sounds.pick_random()
		$Atksound.stream = load(atksound)
		$Atksound.volume_db = -12
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_hp > 0:
		if not return_home and get_parent().game_state == get_parent().STATE_PLAY:
			if target:
				if target.position.y - variance > self.position.y: #enemy below
					self.position.y += vspeed*delta*100
					self.z_index = self.position.y - get_parent().spawnzone_y[0]
					$AnimationPlayer.play("walk")
				elif target.position.y + variance < self.position.y: #enemy above
					self.position.y -= vspeed*delta*100
					self.z_index = self.position.y - get_parent().spawnzone_y[0]
					$AnimationPlayer.play("walk")
				else:
					attack()
			if not target:
				self.position.x += hspeed*delta*100
				$AnimationPlayer.play("walk")
		else:
			if self.position.x > spawn_pos.x and return_home:
				self.scale.x = -1
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
		$AnimationPlayer.play("atk")
		if subtype == "ARCHER": $Atksound.play()
		elif subtype == "WIZARD": $Atksound.play()
		await $AnimationPlayer.animation_finished
		if typeof(target) != TYPE_BOOL: target.hurt()

func hurt():
	current_hp -= 1
	

func play_spawn_sound():
	var rnd
	match subtype:
		"KNIGHT": rnd = spawn_sounds_knight.pick_random()
		"HEALER": rnd = spawn_sounds_healer.pick_random()
		"ARCHER": rnd = spawn_sounds_archer.pick_random()
		"WIZARD": rnd = spawn_sounds_wizard.pick_random()
		"JESTER": rnd = spawn_sounds_jester.pick_random()
	$AudioStreamPlayer.stream = load(rnd)
	$AudioStreamPlayer.play()

func _on_vision_area_entered(area):
	var new_target = area.get_parent()
	if not target and new_target.type == "ENEMY":
		target = new_target
		new_target.connect("died", _on_target_died)

func _on_target_died():
	target = false
	$Vision.monitoring = false
	await get_tree().create_timer(0.5).timeout
	$Vision.monitoring = true

func _on_return_home():
	return_home = true

func _on_game_over():
	queue_free()
