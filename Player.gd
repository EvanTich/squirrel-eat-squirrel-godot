extends Squirrel

signal on_hit(lives_left)
signal win

const MAX_SIZE := 500
const INVINCIBILITY_TIME := .3

export var speed := 100
export var lives := 3

var moving := false
var last_velocity := Vector2.ZERO

onready var invincibility_timer := $InvincibilityTimer

func set_size(size):
	if size >= MAX_SIZE:
		emit_signal("win")
		.set_size(MAX_SIZE)
	else:
		.set_size(size)

func _ready():
	pass

func _process(delta):
	var vel = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	
	if vel.length() > 0:
		vel = vel.normalized() * speed
		moving = true
	else:
		moving = false
	
	if vel.x > 0:
		face_direction(Direction.RIGHT)
	elif vel.x < 0:
		face_direction(Direction.LEFT) 
	
	bounce(moving, delta)
	
	position += vel * delta
	last_velocity = vel

func kill():
	if invincibility_timer.time_left > 0:
		return
	
	lives -= 1
	invincibility_timer.start()
	emit_signal("on_hit", lives)
	
	if lives <= 0:
		.kill()

func _on_Player_area_entered(area):
	if lives > 0:
		fight(area as Squirrel)
