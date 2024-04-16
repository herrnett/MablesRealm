extends Node2D

signal return_home
signal game_over

const STATE_PLAY = 0
const STATE_IDLE = 10
var game_state = STATE_PLAY
const SPAWN_TYPES = ["KNIGHT", "HEALER", "ARCHER", "WIZARD", "JESTER", "BRAINS"]
const enemy_spawnzone_x = [1550, 1900]
const spawnzone_x = [750, 1150]
const spawnzone_y = [800, 950]

var rounds_won = 1

var knight = preload("res://Nodes/knight.tscn")
var healer = preload("res://Nodes/healer.tscn")
var archer = preload("res://Nodes/archer.tscn")
var wizard = preload("res://Nodes/wizard.tscn")
var brains = preload("res://Nodes/brains.tscn")
#var jester = preload("res://Nodes/jester.tscn")

var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.gameState == Globals.STATE_PLAY:
		counter += 1
		if counter > 1000:
			spawn_enemy("BRAINS")
			counter = 0
	elif Globals.gameState == Globals.STATE_GAMEOVER:
		pass
	
func spawn(type, bonus):
	var instance
	var x = randi_range(spawnzone_x[0], spawnzone_x[1])
	var y = randi_range(spawnzone_y[0], spawnzone_y[1])
	var pos = Vector2i(x, y)
	var spawn_z = y - spawnzone_y[0]
	match type:
		"KNIGHT": instance = knight.instantiate()
		"HEALER": instance = healer.instantiate()
		"ARCHER": instance = archer.instantiate()
		"WIZARD": instance = wizard.instantiate()
		#"JESTER": instance = jester.instantiate()
	instance.subtype = type
	instance.position = pos
	instance.z_index = spawn_z
	instance.max_hp += bonus
	instance.current_hp += bonus
	add_child(instance)

func spawn_enemy(type):
	var instance
	var x = randi_range(enemy_spawnzone_x[0], enemy_spawnzone_x[1])
	var y = randi_range(spawnzone_y[0], spawnzone_y[1])
	var pos = Vector2i(x, y)
	var spawn_z = y - spawnzone_y[0]
	match type:
		"BRAINS": instance = brains.instantiate()
	instance.subtype = type
	instance.position = pos
	instance.z_index = spawn_z
	add_child(instance)

func next_round():
	emit_signal("return_home")
	game_state = STATE_IDLE
	await get_tree().create_timer(5).timeout
	for i in rounds_won:
		spawn_enemy("BRAINS")
		spawn_enemy("BRAINS")
		spawn_enemy("BRAINS")
	$Hut.current_hp = 100
	$Hut/HutArea.monitorable = true
	await get_tree().create_timer(10).timeout
	game_state = STATE_PLAY

func new_game():
	rounds_won = 1
	$Hut.current_hp = 100
	$Hut/HutArea.monitorable = true
	$Tower.current_hp = 100
	$Tower/TowerArea.monitorable = true
	for i in rounds_won:
		spawn_enemy("BRAINS")
		spawn_enemy("BRAINS")
		spawn_enemy("BRAINS")
	game_state = STATE_IDLE
	await get_tree().create_timer(15).timeout
	game_state = STATE_PLAY

func _on_hut_died():
	rounds_won += 1
	next_round()

func _on_tower_died():
	emit_signal("game_over")
