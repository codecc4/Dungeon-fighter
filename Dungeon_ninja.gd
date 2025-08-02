extends KinematicBody

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const CROUCH_SPEED = 2.5
const GRAVITY = 20.0
const JUMPFORCE_FORCE = 10.0
const MOUSE_SENSITIVITY = 0.005

var vel = Vector3()
var is_sprinting = false
var is_crouching = false
var mouse_yaw = 0.0
var mouse_pitch = 0.0

onready var camera_pivot = $camera_pivot
onready var camera = $camera_pivot/Camera
onready var ray = $RayCast



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_yaw -= event.relative.x * MOUSE_SENSITIVITY
		mouse_pitch -= event.relative.y *  MOUSE_SENSITIVITY
		
		mouse_pitch = clamp(mouse_pitch, deg2rad(-90), deg2rad(90))
		rotation.y = mouse_yaw
		camera_pivot.rotation.x = mouse_pitch

func _physics_process(delta):
	var direction = Vector3()
	var forward =- transform.basis.z
	var right = transform.basis.x
	
	if Input.is_action_pressed("front"):
		direction += forward
	if Input.is_action_pressed("back"):
		direction -= forward
	if Input.is_action_pressed("right"):
		direction += right
	if Input.is_action_pressed("left"):
		direction -= right
	
	direction = direction.normalized()

	is_crouching = Input.is_action_pressed("crouch")
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching
	
	var speed = WALK_SPEED
	if is_sprinting: 
		speed = SPRINT_SPEED
	elif is_crouching:
		speed = CROUCH_SPEED
	
	vel.x = direction.x * speed
	vel.z = direction.z * speed
	
	#GRAVITY
	if not is_on_floor():
		vel.y -=  GRAVITY * delta
	else:
		if Input.is_action_just_pressed("jump") and ray.is_colliding():
			vel.y = JUMPFORCE_FORCE
		else:
			vel.y = 0
	vel = move_and_slide(vel, Vector3.UP)
