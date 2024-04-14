extends TileMap

#grid variables
const COLS : int = 8
const ROWS : int = 18

#movement variables
const start_pos := Vector2i(4,0)
const preview_pos := Vector2i(11,0)
const further_preview_pos := Vector2i(18,0)
var cur_pos : Vector2i
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array				#per-frame-counter
var steps_req : int = 80		#when reached, will move the piece
var initial_speed : float = 1	#initial/regular falling speed
var current_speed : float		#current falling speed
#var boost := 100				#speed added when pressing down, currently useless (see _process)

#tilemap variables
var tile_id : int = 0
var puyos_atlas : Array
var next_puyos_atlas : Array

#layer variables
var board_layer : int = 0
var active_layer : int = 1

#puyos: second puyo (value) rotates around first
var puyos_0 := [Vector2i(1, 1), Vector2i(1, 0)]
var puyos_90 := [Vector2i(1, 1), Vector2i(2, 1)]
var puyos_180 := [Vector2i(1, 1), Vector2i(1, 2)]
var puyos_270 := [Vector2i(1, 1), Vector2i(0, 1)]
var puyos := [puyos_0, puyos_90, puyos_180, puyos_270]

#puyo variables
const number_of_preview_puyos := 3
const initial_rotation := 3
var rotation_index : int = 3
var current_puyos : Array
var await_new_puyo := false
var new_puyo_waittime : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	#reset variables
	current_speed = initial_speed
	steps = [0, 0, 0]
	$HUD/GameOverLabel.hide()
	
	puyos_atlas = random_puyos()
	for i in number_of_preview_puyos:
		next_puyos_atlas.append(random_puyos())
	create_puyos()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#check for input
	if not await_new_puyo:
		if Input.is_action_just_pressed("ui_down"):
			#steps[2] += boost * delta #needs is_action_pressed("ui_down")
			steps[2] = steps_req
		elif Input.is_action_just_pressed("ui_left"):
			steps[0] = steps_req
		elif Input.is_action_just_pressed("ui_right"):
			steps[1] = steps_req
		elif Input.is_action_just_pressed("ui_select"):
			rotate_puyos()
	
		#apply downward movement every frame
		steps[2] += current_speed * 100 * delta
		
		#move the puyos
		for i in range(steps.size()):
			if steps[i] >= steps_req:
				move_puyos(directions[i], delta)
				steps[i] = 0
	
	#if landed before, wait for a new puyo to spawn
	if await_new_puyo:
		new_puyo_waittime += current_speed * 100 * delta
		if new_puyo_waittime >= steps_req:
			puyos_atlas = next_puyos_atlas.pop_front()
			next_puyos_atlas.append(random_puyos())
			create_puyos()
			await_new_puyo = false
			new_puyo_waittime = 0

func create_puyos():
	#reset everything
	steps = [0, 0, 0]
	cur_pos = start_pos
	rotation_index = initial_rotation
	current_puyos = puyos[rotation_index]
	
	draw_puyos(current_puyos, cur_pos, puyos_atlas)
	draw_next_puyos(puyos[3], preview_pos, next_puyos_atlas)
	play_spawn_sound()

func clear_puyos():
	for i in current_puyos:
		erase_cell(active_layer, cur_pos + i)

func rotate_puyos():
	if can_rotate():
		clear_puyos()
		rotation_index = (rotation_index + 1) % 4
		current_puyos = puyos[rotation_index]
		draw_puyos(current_puyos, cur_pos, puyos_atlas)

func move_puyos(direction, delta):
	if can_move(direction):
		clear_puyos()
		cur_pos += direction
		draw_puyos(current_puyos, cur_pos, puyos_atlas)
	else:
		if direction == Vector2i.DOWN: 
			land_puyos()
			await_new_puyo = true

func draw_puyos(puyos, pos, atlas):
	var index = 0
	for i in puyos:
		set_cell(active_layer, pos + i, tile_id, atlas[index])
		index += 1

func draw_next_puyos(puyos, pos, atlas):
	var index = 0
	#draw first preview
	for i in puyos:
		set_cell(active_layer, pos + i, tile_id, atlas[0][index] + Vector2i.DOWN)
		index += 1
	#draw remaining previews
	index = 0
	for i in number_of_preview_puyos:
		print(i)
		for j in puyos:
			if i != 0:
				print("hi")
				set_cell(active_layer, further_preview_pos + Vector2i(i*3, 0) + j, tile_id, atlas[i][index] + Vector2i.DOWN)
				index += 1
		index = 0

func random_puyos():
	var a = Vector2i(randi_range(0,3), 0)
	var b = Vector2i(randi_range(0,3), 0)
	return [a, b]

func can_move(direction):
	#check if there is space to move
	var can_move = true
	for i in current_puyos:
		if not is_free(i + cur_pos + direction):
			can_move = false
	return can_move

func can_rotate():
	var can_rotate = true
	var temp_rotation_index = (rotation_index + 1) % 4
	for i in puyos[temp_rotation_index]:
		if not is_free(i + cur_pos):
			can_rotate = false
	return can_rotate

func is_free(pos):
	return get_cell_source_id(board_layer, pos) == -1

func land_puyos():
	#remove puyos from active layer, move to board
	var index = 0
	for i in current_puyos:
		if not can_move(Vector2i.DOWN):
			if current_puyos == puyos[0] or current_puyos == puyos[2]:
				erase_cell(active_layer, cur_pos + i)
				set_cell(board_layer, cur_pos + i, tile_id, puyos_atlas[index])
				index += 1
			else:
				#TODO: hier einzelne puyos prüfen und ggf setzen
				erase_cell(active_layer, cur_pos + i)
				
				set_cell(board_layer, cur_pos + i, tile_id, puyos_atlas[index])
				index += 1
	play_land_sound()

func play_land_sound():
	var rnd = randi_range(0,3)
	match rnd:
		0:
			$AudioStreamPlayer.stream = load("res://sfx/Bup_1.ogg")
			$AudioStreamPlayer.play()
		1:
			$AudioStreamPlayer.stream = load("res://sfx/Bup_2.ogg")
			$AudioStreamPlayer.play()
		2:
			$AudioStreamPlayer.stream = load("res://sfx/Bup_3.ogg")
			$AudioStreamPlayer.play()
		3:
			$AudioStreamPlayer.stream = load("res://sfx/Bup_4.ogg")
			$AudioStreamPlayer.play()

func play_spawn_sound():
	var rnd = randi_range(0,1)
	match rnd:
		0:
			$AudioStreamPlayer.stream = load("res://sfx/puyo_spawn_1.ogg")
			$AudioStreamPlayer.play()
		1:
			$AudioStreamPlayer.stream = load("res://sfx/puyo_spawn_2.ogg")
			$AudioStreamPlayer.play()
