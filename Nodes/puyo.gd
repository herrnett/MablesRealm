extends TileMap

#preloads
var plaster_red = preload("res://gfx/plaster_red2.png")
var plaster_yellow = preload("res://gfx/plaster_yellow.png")
var plaster_green = preload("res://gfx/plaster_green.png")
var plaster_blue = preload("res://gfx/plaster_blue.png")


#signals. use emit_signal("name") to emit
signal spawn_ally(bonus : int, type : String)
signal game_lost

#test sets
var test_puyos = [Vector2i(2, 0), Vector2i(2, 0)]
var test_next_puyos = [[Vector2i(1, 0), Vector2i(1, 0)], \
						[Vector2i(0, 0), Vector2i(0, 0)], \
						[Vector2i(3, 0), Vector2i(3, 0)]]

#grid variables
const COLS : int = 8
const ROWS : int = 18
const TILE_SIZE : int = 64

#movement variables
const start_pos := Vector2i(4,0)
const preview_pos := Vector2i(12,0)
const further_preview_pos := Vector2i(15,0)
var cur_pos : Vector2i
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array				#per-frame-counter
var steps_req : int = 80		#when reached, will move the piece
var initial_speed : float = 5	#initial/regular falling speed
var current_speed : float		#current falling speed

#tilemap variables
var tile_id : int = 0
var puyos_atlas : Array
var next_puyos_atlas : Array
var red_atlas : Array
var red_matches : Array
var yellow_matches : Array
var green_matches : Array
var blue_matches : Array
var matches := [red_matches, yellow_matches, green_matches, blue_matches]


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

#plaster variables
var yellow_atlas : Array
var green_atlas : Array
var blue_atlas : Array
var atlases := [red_atlas, yellow_atlas, green_atlas, blue_atlas]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func new_game():
	#reset variables
	current_speed = initial_speed
	steps = [0, 0, 0]
	for i in atlases: i = []
	
	#puyos_atlas = random_puyos()
	#for i in number_of_preview_puyos:
		#next_puyos_atlas.append(random_puyos())
	
	#TEST
	puyos_atlas = test_puyos
	next_puyos_atlas = test_next_puyos
	
	create_puyos()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.gameState == Globals.STATE_PLAY:
		#check for input
		if not await_new_puyo:
			if Input.is_action_pressed("ui_down"):
				steps[2] += steps_req
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
					move_puyos(directions[i])
					steps[i] = 0
		
		#if landed before, wait for a new puyo to spawn
		if await_new_puyo:
			new_puyo_waittime += current_speed * 100 * delta
			if new_puyo_waittime >= steps_req:
				puyos_atlas = next_puyos_atlas.pop_front()
				next_puyos_atlas.append(random_puyos())
				if is_free(start_pos + Vector2i.DOWN) \
				and is_free(start_pos + Vector2i.DOWN + Vector2i.RIGHT):
					create_puyos()
					await_new_puyo = false
					new_puyo_waittime = 0
				else: game_over()

func create_puyos():
	#reset everything
	steps = [0, 0, 0]
	cur_pos = start_pos
	rotation_index = initial_rotation
	current_puyos = puyos[rotation_index]
	
	draw_puyos(current_puyos, cur_pos, puyos_atlas)
	draw_next_puyos(puyos[3], preview_pos, next_puyos_atlas)

func clear_puyos():
	for i in current_puyos:
		erase_cell(active_layer, cur_pos + i)

func rotate_puyos():
	if can_rotate():
		clear_puyos()
		rotation_index = (rotation_index + 1) % 4
		current_puyos = puyos[rotation_index]
		draw_puyos(current_puyos, cur_pos, puyos_atlas)

func move_puyos(direction):
	if can_move(direction):
		clear_puyos()
		cur_pos += direction
		draw_puyos(current_puyos, cur_pos, puyos_atlas)
	else:
		if direction == Vector2i.DOWN: 
			land_puyos()
			await_new_puyo = true

func draw_puyos(this_puyos, pos, atlas):
	var index = 0
	for i in this_puyos:
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
		for j in puyos:
			if i != 0:
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
	var final_puyo_pos = []
	
	#remove puyos from active layer, move to board
	var index = 0
	for i in current_puyos:
		if not can_move(Vector2i.DOWN):
			if current_puyos == puyos[0] or current_puyos == puyos[2]:
				erase_cell(active_layer, cur_pos + i)
				set_cell(board_layer, cur_pos + i, tile_id, puyos_atlas[index])
				final_puyo_pos.append(cur_pos + i)
				index += 1
			else:
				erase_cell(active_layer, cur_pos + i)
				if not is_free(cur_pos + i + Vector2i.DOWN):
					set_cell(board_layer, cur_pos + i, tile_id, puyos_atlas[index])
					final_puyo_pos.append(cur_pos + i)
				else:
					var final_pos = cur_pos + i
					while is_free(final_pos + Vector2i.DOWN):
						final_pos = final_pos + Vector2i.DOWN
					#TODO: Animate the fall
					set_cell(board_layer, final_pos, tile_id, puyos_atlas[index])
					final_puyo_pos.append(final_pos)
				index += 1
	update_local_chain(final_puyo_pos)
	play_land_sound()

func update_local_chain(puyo_positions):
	for puyo in puyo_positions:
		var puyo_type = get_cell_atlas_coords(board_layer, puyo)
		var neighbors = get_surrounding_cells(puyo)
		for neighbor in neighbors:
			var neighbor_type = get_cell_atlas_coords(board_layer, neighbor)
			if puyo_type == neighbor_type:
				update_color_atlas(puyo_type, puyo, neighbor)
	create_plasters()
	#check_for_chains()

func check_for_chains(combo = 0):
	var red_chains = 0
	var yellow_chains = 0
	var green_chains = 0
	var blue_chains = 0
	for color_matches in matches:
		var not_chains = []
		while color_matches.size() > 0:
			var temp_collection = []
			temp_collection.append(color_matches.pop_back())
			var counter = 0
		
			while counter < temp_collection.size():
				#loop over array from back
				for i in range(color_matches.size()-1, -1, -1):
					if temp_collection[counter].x == color_matches[i].x \
					or temp_collection[counter].x == color_matches[i].y \
					or temp_collection[counter].y == color_matches[i].x \
					or temp_collection[counter].y == color_matches[i].y:
						temp_collection.append(color_matches[i])
						color_matches.remove_at(i)
				counter += 1
			
			if temp_collection.size() < 4:
				color_matches.append_array(not_chains)
			else: score(temp_collection)
		color_matches = not_chains
	#TODO: puyos bewegen,(alle gelöschten + up), listen updaten, erneut prüfen. 
	# wenn was da ist: combo+1, nochmal. 

#TODO: Löschen fancy aussehen lassen
func score(chain):
	var bonus = chain.size()-4
	#TODO: lösche chain und links, spawne
	


#gets the type (Vector2i of tileset) of match, and the matching objects
func update_color_atlas(puyo_type, puyo, neighbor):
	var a = map_to_local(puyo)
	var b = map_to_local(neighbor)
	var orient
	if a.x == b.x: orient = 0 #vertical match
	else: orient = 1 #horizontal match
	
	var shared_border
	if orient == 0: shared_border = calculate_shared_border(a.y, b.y)
	else: shared_border = calculate_shared_border(a.x, b.x)
	var x
	var y
	var coordinates
	#var somethingchanged = false
	if orient == 0: #vert plaster, val is x
		x = a.x
		y = shared_border
	else:
		x = shared_border
		y = a.y
	coordinates = Vector2i(x, y)

	match puyo_type:
		Vector2i(0,0):
			if not red_atlas.has([orient, coordinates]):
				red_atlas.append([orient, coordinates])
				red_matches.append([puyo,neighbor])
				#somethingchanged = true
		Vector2i(1,0):
			if not yellow_atlas.has([orient, coordinates]):
				yellow_atlas.append([orient, coordinates])
				yellow_matches.append([puyo,neighbor])
				#somethingchanged = true
		Vector2i(2,0):
			if not green_atlas.has([orient, coordinates]):
				green_atlas.append([orient, coordinates])
				green_matches.append([puyo,neighbor])
				#somethingchanged = true
		Vector2i(3,0):
			if not blue_atlas.has([orient, coordinates]):
				blue_atlas.append([orient, coordinates])
				blue_matches.append([puyo,neighbor])
				#somethingchanged = true
	#if somethingchanged: play_land_sound()

func create_plasters():
	var color = 0
	for atlas in atlases:
		for plaster_info in atlas:
			draw_plaster(plaster_info, color)
		color += 1

func draw_plaster(info, color):
	var plaster = Sprite2D.new()
	match color:
		0: plaster.texture = plaster_red
		1: plaster.texture = plaster_yellow
		2: plaster.texture = plaster_green
		3: plaster.texture = plaster_blue
	if info[0] == 1:
		plaster.rotation = 1.5
	plaster.position = info[1]
	add_child(plaster)

func calculate_shared_border(a, b):
	if a > b: return a - (TILE_SIZE/2)
	else: return b - (TILE_SIZE/2)

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

func game_over():
	emit_signal("game_lost")
