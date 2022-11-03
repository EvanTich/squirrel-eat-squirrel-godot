class_name Grass
extends Sprite

const NUM_GRASS_TEXTURES = 4

func _ready():
	randomize()
	texture = load("res://art/grass%d.png" % (randi() % NUM_GRASS_TEXTURES + 1))

func _on_VisibilityNotifier2D_screen_exited():
	Globals.emit_signal("on_grass_visibility", false)
	set_process(false)
	visible = false
	Globals.visible_grass -= 1

func _on_VisibilityNotifier2D_screen_entered():
	Globals.emit_signal("on_grass_visibility", true)
	set_process(true)
	visible = true
	Globals.visible_grass += 1
