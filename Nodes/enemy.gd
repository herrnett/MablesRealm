extends AnimatedSprite2D

signal died

const type := "ENEMY"
var subtype
const hspeed : int = 3
const vspeed : float = 0.5
var spawn_pos
var variance : int = 0
var return_home = false

const spawn_sounds_brains = ["res://sfx/Spawn_Brains_1.ogg", \
					"res://sfx/Spawn_Brains_2.ogg", \
					"res://sfx/Spawn_Brains_3.ogg", \
					"res://sfx/Spawn_Brains_4.ogg", \
					"res://sfx/Spawn_Brains_5.ogg", \
					"res://sfx/Spawn_Brains_6.ogg"]

const spawn_sounds_healer = \
				   ["res://sfx/Spawn_Healer_1.ogg", \
					"res://sfx/Spawn_Healer_2.ogg", \
					"res://sfx/Spawn_Healer_3.ogg", \
					"res://sfx/Spawn_Healer_4.ogg", \
					"res://sfx/Spawn_Healer_5.ogg", \
					"res://sfx/Spawn_Healer_6.ogg"]

const spawn_sounds_archer = \
					["res://sfx/Spawn_Archer_1.ogg", \
					 "res://sfx/Spawn_Archer_2.ogg", \
					 "res://sfx/Spawn_Archer_3.ogg", \
					 "res://sfx/Spawn_Archer_4.ogg", \
					 "res://sfx/Spawn_Archer_5.ogg"]


const spawn_sounds_wizard = \
					["res://sfx/Spawn_Wizard_1.ogg", \
					 "res://sfx/Spawn_Wizard_2.ogg", \
					 "res://sfx/Spawn_Wizard_3.ogg", \
					 "res://sfx/Spawn_Wizard_4.ogg", \
					 "res://sfx/Spawn_Wizard_5.ogg", \
					 "res://sfx/Spawn_Wizard_6.ogg", \
					 "res://sfx/Spawn_Wizard_7.ogg", \
					 "res://sfx/Spawn_Wizard_8.ogg"]

var current_hp : int = 3
var max_hp: int = 3
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_pos = self.position
	variance = randi_range(0,100)
	get_parent().connect("game_over", _on_game_over)
	$AudioStreamPlayer.volume_db = -12
	play_spawn_sound()

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
				self.position.x -= hspeed*delta*100
				$AnimationPlayer.play("walk")
		else:
			if self.position.x > spawn_pos.x and return_home:
				self.scale.x = -1
				self.position.x += hspeed*delta*100
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
		await $AnimationPlayer.animation_finished
		if typeof(target) != TYPE_BOOL: target.hurt()

func hurt():
	current_hp -= 1
	
func play_spawn_sound():
	var rnd
	match subtype:
		"BRAINS": rnd = spawn_sounds_brains.pick_random()
		"HEALER": rnd = spawn_sounds_healer.pick_random()
		"ARCHER": rnd = spawn_sounds_archer.pick_random()
		"WIZARD": rnd = spawn_sounds_wizard.pick_random()
	$AudioStreamPlayer.stream = load(rnd)
	$AudioStreamPlayer.play()

func _on_vision_area_entered(area):
	var parent = area.get_parent()
	if not target and parent.type == "ALLY":
		target = parent
		parent.connect("died", _on_target_died)

func _on_target_died():
	target = false
	$Vision.monitoring = false
	await get_tree().create_timer(0.5).timeout
	$Vision.monitoring = true

func _on_return_home():
	return_home = true

func _on_game_over():
	queue_free()
