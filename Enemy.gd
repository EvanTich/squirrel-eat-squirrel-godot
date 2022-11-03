class_name Enemy
extends Squirrel

const TURN_CHANCE := .002
const MAX_SIZE := 150
const MAX_SPEED := 80
const MIN_SPEED := 20

export var velocity := Vector2.ZERO

func reset(pos: Vector2):
	.reset(pos)
	new_velocity()
	
func set_size(size):
	if size > MAX_SIZE:
		.set_size(MAX_SIZE)
	else:
		.set_size(size)

func _ready():
	new_velocity()

func _process(delta):
	bounce(true, delta)
	
	position += velocity * delta
	if randf() <= TURN_CHANCE:
		new_velocity()

static func clamp_rand(minimum, maximum):
	return rand_range(minimum, maximum) * (1 if randf() < .5 else -1)

func new_velocity():
	velocity = Vector2(clamp_rand(MIN_SPEED, MAX_SPEED), clamp_rand(MIN_SPEED, MAX_SPEED))
	if velocity.x > 0:
		face_direction(Direction.RIGHT)
	else:
		face_direction(Direction.LEFT)

func _on_VisibilityNotifier2D_screen_exited():
	Globals.emit_signal("on_enemy_visibility", false, self)
	Globals.visible_enemy -= 1
	visible = false
	set_process(false)

func _on_VisibilityNotifier2D_screen_entered():
	Globals.emit_signal("on_enemy_visibility", true, self)
	Globals.visible_enemy += 1
	visible = true
	set_process(true)
