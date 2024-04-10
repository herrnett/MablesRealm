extends Node

# Offsets for play area
const x_offset = 3
const y_offset = 35-3
const forbidden_x = 6
const forbidden_y = 3
const s_person = [2,1]
const m_person = [3,2]
const l_person = [4,3]

var current_stage = 1
var current_people
var stage_dim_x
var stage_dim_y
# stage is a dict that for every coordinate puts a status of that cell
# States:	0: Out of bounds
#			1: Entrance root
#			2: Entrance forbidden
#			100: Stage (empty)
#			101: Wall
#			102: Hallway
#			103: Room
#			104: Door
#			105: Stairs

var stage = {}

var won = false

func load_stage(stage_num: int):
	var size
	var entrance
	match stage_num:
		1: 
			size = Stages.stage01[0]
			entrance = Stages.stage01[1]
			current_people = Stages.stage01[2]
	build_stage(size, entrance)

#Builds the stage
func build_stage(stage_size:Vector2i, entrance:Vector2i):
	stage.clear()
	stage_dim_x = stage_size.x
	stage_dim_y = stage_size.y
	for y in range(stage_size.y):
		for x in range(stage_size.x):
			stage[Vector2i(x+x_offset, y_offset-y)] = 100
	for x in forbidden_x:
		for y in forbidden_y:
			stage[Vector2i(entrance.x+x_offset+x, y_offset-entrance.y-y)] = 2
			stage[Vector2i(entrance.x+x_offset-x, y_offset-entrance.y-y)] = 2
	stage[Vector2i(entrance.x+x_offset, y_offset-entrance.y)] = 1
#TODO: Add variations
	return stage
