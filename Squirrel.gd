class_name Squirrel
extends Area2D

enum Direction { LEFT, RIGHT }

signal hunger_sated(new_size) # for now >:)
signal hop_state_enter(new_state, old_state)
signal death(killer)

const BOUNCE_RATE := 40
const BOUNCE_HEIGHT := 5
const EAT_SIZE_LOSS := 3
const EAT_SIZE_SLACK := 5

enum BounceState { ON_GROUND, GOING_UP, GOING_DOWN }

export var size := 16.0 setget set_size, get_size

var bounce_state = BounceState.ON_GROUND
var bounce_offset = 0
onready var sprite := $Sprite

func set_size(s):
	size = s
	scale.x = size / 16.0
	scale.y = size / 16.0
	
func get_size():
	return size

# this can be an animation
func bounce(is_moving, delta):
	var next_state = null
	match bounce_state:
		BounceState.ON_GROUND:
			if is_moving:
				next_state = BounceState.GOING_UP
		BounceState.GOING_UP:
			bounce_offset += BOUNCE_RATE * delta
			if bounce_offset >= BOUNCE_HEIGHT:
				next_state = BounceState.GOING_DOWN
		BounceState.GOING_DOWN:
			bounce_offset -= BOUNCE_RATE * delta
			if bounce_offset <= 0:
				next_state = BounceState.ON_GROUND
	
	sprite.offset.y = -bounce_offset
	
	if next_state != null:
		emit_signal("hop_state_enter", next_state, bounce_state)
		bounce_state = next_state

func eat(squirrel: Squirrel):
	set_size(size + squirrel.size / EAT_SIZE_LOSS)
	squirrel.kill()
	emit_signal("hunger_sated", size)

func face_direction(dir):
	if dir == Direction.LEFT:
		sprite.flip_h = false
	elif dir == Direction.RIGHT:
		sprite.flip_h = true

# call this when two squirrels collide
func fight(other: Squirrel):
	if size - other.size > EAT_SIZE_SLACK:
		eat(other)
		return true
	elif other.size - size > EAT_SIZE_SLACK:
		# other squirrels don't need to eat, only the player
#		other.eat(self)
		kill()
	return false

func kill():
	# remove from life
	set_process(false)
	visible = false
	emit_signal("death", self)
