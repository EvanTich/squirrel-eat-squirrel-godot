extends Camera2D

var shake_intensity = 0
var default_offset = offset

onready var tween = $Tween
onready var timer = $Timer

func _ready():
	set_process(false)
	Globals.current_camera = self
	randomize()

func _process(delta):
	offset = Vector2(rand_range(-1, 1) * shake_intensity, rand_range(-1, 1) * shake_intensity)

func shake(time, intensity):
	timer.wait_time = time
	shake_intensity = intensity
	set_process(true)
	timer.start()

func _on_Timer_timeout():
	set_process(false)
	tween.interpolate_property(self, "offset", offset, default_offset, 0.1, 6, 2)
