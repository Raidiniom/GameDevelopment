extends CharacterBody3D

@export var move_speed := 2.0
@export var jump_velocity := 8.0
@export var gravity := 30.0
@export var max_x_limit := 6.0
@export var death_y_level := -10.0

var is_dead := false
var spawn_position : Vector3

func _ready():
	spawn_position = global_position

func _physics_process(delta):

	if is_dead:
		if Input.is_action_just_pressed("respawn"):
			respawn()
		return

	# ---- LEFT / RIGHT MICRO MOVEMENT ----
	var input_dir := 0.0
	
	if Input.is_action_pressed("left"):
		input_dir -= 1
	if Input.is_action_pressed("right"):
		input_dir += 1
	
	velocity.x = input_dir * move_speed
	
	# Clamp player inside lane bounds
	var new_x = global_position.x + velocity.x * delta
	new_x = clamp(new_x, -max_x_limit, max_x_limit)
	global_position.x = new_x
	
	# ---- GRAVITY ----
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# ---- JUMP ----
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	move_and_slide()
	

func _on_ToxicTrigger_body_entered(body):
	if body == self:
		die()

func die():
	is_dead = true
	print("Player Died")

func respawn():
	global_position = spawn_position
	velocity = Vector3.ZERO
	is_dead = false
	print("Respawned")
