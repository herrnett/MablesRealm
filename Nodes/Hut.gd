extends Node2D

const type = "ENEMY"

signal died

var max_hp = 100
var current_hp = 1

func hurt():
	current_hp-=1
	if current_hp < 1:
		emit_signal("died")
		$HutArea.monitorable = false
