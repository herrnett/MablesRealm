extends Node2D

signal return_home
const STATE_PLAY = 0
const STATE_IDLE = 10
var game_state = STATE_PLAY
const SPAWN_TYPES = ["KNIGHT", "HEALER", "ARCHER", "WIZARD", "JESTER"]
const spawnzone_x = [750, 1150]
const spawnzone_y = [800, 950]

var knight = preload("res://Nodes/knight.tscn")
#var healer = preload("res://Nodes/healer.tscn")
#var archer = preload("res://Nodes/archer.tscn")
#var wizard = preload("res://Nodes/wizard.tscn")
#var jester = preload("res://Nodes/jester.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.gameState == Globals.STATE_PLAY:
		pass
	
func spawn(type, bonus):
	var instance
	var x = randi_range(spawnzone_x[0], spawnzone_x[1])
	var y = randi_range(spawnzone_y[0], spawnzone_y[1])
	var pos = Vector2i(x, y)
	var spawn_z = y - spawnzone_y[0]
	match type:
		"KNIGHT": instance = knight.instantiate()
		#"HEALER": instance = healer.instantiate()
		#"ARCHER": instance = archer.instantiate()
		#"WIZARD": instance = wizard.instantiate()
		#"JESTER": instance = jester.instantiate()
	instance.position = pos
	instance.z_index = spawn_z
	instance.max_hp += bonus
	instance.current_hp += bonus
	add_child(instance)

func new_game():
	emit_signal("return_home")
	game_state = STATE_IDLE
	await get_tree().create_timer(10).timeout
	game_state = STATE_PLAY

func _on_hut_died():
	new_game()
