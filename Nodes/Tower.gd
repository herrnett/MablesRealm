extends Node2D

const type = "ALLY"

signal died

var max_hp = 100
var current_hp = 100

func _process(delta):
	$Control.size.x = 1.9*current_hp

func hurt():
	current_hp-=1
	if current_hp < 1:
		emit_signal("died")
		$TowerArea.monitorable = false
