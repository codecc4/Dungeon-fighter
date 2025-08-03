extends KinematicBody

var vel = Vector3()
const SPEED = 100.0
const LIFETIME = 2.0
var life_timer = 0

func _ready():
	set_as_toplevel(true)
	

func _physics_process(delta):
	move_and_collide(vel * delta)
	life_timer += delta
	if life_timer > LIFETIME:
		queue_free()
