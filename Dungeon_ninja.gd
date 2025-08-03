extends KinematicBody

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const CROUCH_SPEED = 2.5
const GRAVITY = 20.0
const JUMPFORCE_FORCE = 10.0
const MOUSE_SENSITIVITY = 0.005
const MAX_AMMO = 10
const RECOIL_DISTANCE = 0.1

var ammo = MAX_AMMO
var vel = Vector3()
var is_sprinting = false
var is_crouching = false
var mouse_yaw = 0.0
var mouse_pitch = 0.0


#spawn bullet from muzzle
var Bulletscene = preload("res://scene/bullet.tscn")
onready var muzzle = $camera_pivot/Camera/gun/muzzle


onready var camera_pivot = $camera_pivot
onready var camera = $camera_pivot/Camera
onready var ray = $RayCast
onready var raycastb = $camera_pivot/Camera/RayCast_b
onready var gun = $camera_pivot/Camera/gun
onready var gunshot = $camera_pivot/Camera/gun/gunshot
onready var tween = $camera_pivot/Camera/gun/Tween


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycastb.enabled = true

func _input(event):
	if event is InputEventMouseMotion:
		mouse_yaw -= event.relative.x * MOUSE_SENSITIVITY
		mouse_pitch -= event.relative.y *  MOUSE_SENSITIVITY
		
		mouse_pitch = clamp(mouse_pitch, deg2rad(-90), deg2rad(90))
		rotation.y = mouse_yaw
		camera_pivot.rotation.x = mouse_pitch
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		ammo = MAX_AMMO 
	

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
	

func shoot():
	if ammo <= 0:
		print("out of ammo!")
		return
	ammo -=1
	
	#playing sounds
	if gunshot:
		gunshot.play()
	
	#recoil animation
	if tween:
		var start_pos = gun.transform.origin
		var recoil_pos = start_pos + Vector3(0, 0, RECOIL_DISTANCE)
		tween.interpolate_property(gun, "translation", recoil_pos, start_pos, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.interpolate_property(gun, "translation", recoil_pos, start_pos, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.05)
		tween.start()
	
	#raycast hit
	if raycastb.is_colliding():
		var hit_pos = raycastb.get_collision_point()
		var hit_obj = raycastb.get_collider()
		print("hit: ", hit_obj.name, "at" ,hit_pos)
	
	#spawning bullet
	var bullet = Bulletscene.instance()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = muzzle.global_transform.origin
	bullet.vel = -camera.global_transform.basis.z * 100 #camera forward

