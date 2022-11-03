extends Node

const NUM_GRASS := 75
const NUM_ENEMY := 25
const WIN_SIZE := 300

var grass_inst = preload("res://Grass.tscn")
var enemy_inst = preload("res://Enemy.tscn")

onready var player := $Player
onready var enemies := $Enemies
onready var grass := $Grass

func _ready():
	randomize()
	Globals.connect("on_grass_visibility", self, "_on_grass_visibility")
	Globals.connect("on_enemy_visibility", self, "_on_enemy_visibility")
	spawn_grass()

func current_screen():
	return get_viewport().get_visible_rect().size

func spawn_grass():
	var cur_screen = current_screen()
	for _i in range(NUM_GRASS):
		var e = grass_inst.instance()
		e.position.x = rand_range(-cur_screen.x / 2, cur_screen.x / 2)
		e.position.y = rand_range(-cur_screen.y / 2, cur_screen.y / 2)
		grass.add_child(e)

func spawn_one_grass(pos: Vector2):
	var e: Grass = grass_inst.instance()
	e.position = pos
	grass.call_deferred("add_child", e)

func spawn_one_enemy(pos: Vector2):
	var e: Enemy = enemy_inst.instance()
	var size = rand_range(player.size / 2, player.size * 2)
	e.set_size(size)
	e.position = pos
	enemies.call_deferred("add_child", e)

static func point_on_bounds(bounds: Vector2, dir: Vector2):
	var y = bounds.x * dir.y / dir.x
	if abs(y) < bounds.y:
		return Vector2(bounds.x, y) * sign(dir.x)
	return Vector2(bounds.y * dir.x / dir.y, bounds.y) * sign(dir.y)

static func dir(angle):
	return Vector2(cos(angle), sin(angle))

static func random_dir():
	var angle = randf() * 2 * PI
	return dir(angle)

func reset():
	# reset player, enemies, and grass (reload the scene)
	get_tree().reload_current_scene()

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		reset()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	for _i in range(randf() * (NUM_ENEMY - enemies.get_child_count())):
		var dir: Vector2
		if player.last_velocity.length() <= .1:
			dir = dir(rand_range(0, 2 * PI))
		else:
			dir = dir(player.last_velocity.angle() + rand_range(-PI / 4, PI / 4))
		
		spawn_one_enemy(point_on_bounds(current_screen() / 2, dir) + player.position)

func _on_grass_visibility(visible):
	# if not visible, spawn a grass in the direction the player is moving
	if not visible:
		var angle = player.last_velocity.angle()
		var dir = dir(angle + rand_range(-PI / 4, PI / 4))
		spawn_one_grass(
			point_on_bounds(current_screen() / 2, dir)
			+ 20 * randf() * dir
			+ player.position
		)

func _on_enemy_visibility(visible, _enemy):
	if not visible and Globals.visible_enemy < NUM_ENEMY:
		var dir: Vector2
		if player.last_velocity.length() <= .1:
			dir = dir(rand_range(0, 2 * PI))
		else:
			dir = dir(player.last_velocity.angle() + rand_range(-PI / 4, PI / 4))
		
		spawn_one_enemy(point_on_bounds(current_screen() / 2, dir) + player.position)

func _on_Player_death(killer):
	$"UI/LoseLabel".visible = true

func _on_Player_win():
	$"UI/WinLabel".visible = true

func _on_Player_hunger_sated(new_size):
	# chomp?
	Globals.current_camera.shake(.1, new_size / 16.0)

func _on_Player_on_hit(lives_left):
	# shake screen? play sound?
	Globals.current_camera.shake(.2, 5)
