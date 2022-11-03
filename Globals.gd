extends Node

# globals.

signal set_camera
signal on_grass_visibility(visible)
signal on_enemy_visibility(visible, node)

var current_camera: Camera2D setget set_camera, get_camera
var visible_grass: int = 0
var visible_enemy: int = 0

func set_camera(camera):
	current_camera = camera
	emit_signal("set_camera")

func get_camera():
	return current_camera
