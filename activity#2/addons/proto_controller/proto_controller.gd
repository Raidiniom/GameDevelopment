# ProtoController v1.0 by Brackeys (Multiplayer Fixed)
extends CharacterBody3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 4.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "left"
## Name of Input Action to move Right.
@export var input_right : String = "right"
## Name of Input Action to move Forward.
@export var input_forward : String = "forward"
## Name of Input Action to move Backward.
@export var input_back : String = "backward"
## Name of Input Action to Jump.
@export var input_jump : String = "jump"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## Character Fall Mechanic
var fall_velocity : float = 0.0
var was_on_floor : bool = true

@export var fall_dmg_threshold : float = 5.0
@export var fall_dmg_multiplier : float = 12.5

var health : int = 100
var is_dead : bool = false
var spawn_position : Vector3

# Track if this is MY character
var is_my_character : bool = false

## IMPORTANT REFERENCES
@onready var health_bar: Label3D = $Healthbar
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var cam = $Head/Camera3D
@onready var jump_sound = $jump_sound
@onready var walk_sound = $walk_sound
@onready var takedmg_sound = $takedmg_sound

func _ready():
	add_to_group("player")
	
	# Set authority based on node name
	var peer_id = name.to_int()
	set_multiplayer_authority(peer_id)
	
	# Check if this is MY character
	is_my_character = multiplayer.get_unique_id() == peer_id
	
	# Only enable camera for local player
	if cam:
		cam.current = is_my_character
	
	# Only capture mouse for local player
	if is_my_character:
		capture_mouse()
	
	# Rest of your _ready code...
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	update_healthbar()

func _input(event: InputEvent) -> void:
	# ONLY process input for MY character
	if not is_my_character:
		return
		
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	if event is InputEventScreenDrag:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If this is NOT my character, just apply gravity and move with physics
	# but don't process input
	if not is_my_character:
		# Apply gravity for all players
		if has_gravity and not is_on_floor():
			velocity += get_gravity() * delta
		
		# Still move and slide for physics
		move_and_slide()
		return
	
	# FROM HERE ON, ONLY MY CHARACTER PROCESSES INPUT
	
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Death Mechanic
	if is_dead:
		if Input.is_action_just_pressed("respawn"):
			respawn()
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity
			jump_sound.play()
			print("Jumped")

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			# Only play walk sound for local player
			if is_my_character and is_on_floor():
				walk_sound.play()
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Track maximum fall speed
	if not is_on_floor():
		fall_velocity = min(fall_velocity, velocity.y)
	
	# Use velocity to actually move
	move_and_slide()
	
	# ONLY the server should sync positions if using MultiplayerSynchronizer
	# Remove or comment out this line if using MultiplayerSynchronizer:
	# SyncPosition.rpc(global_position)
	
	# Landing detection
	if is_on_floor() and not was_on_floor:
		var impact_speed = abs(fall_velocity)
		print("Impact Speed: ", impact_speed)
		
		if impact_speed > fall_dmg_threshold:
			var damage = (impact_speed - fall_dmg_threshold) * fall_dmg_multiplier
			apply_damage(damage)
			
		fall_velocity = 0.0
		
	was_on_floor = is_on_floor()

func apply_damage(amount: float):
	health -= amount
	takedmg_sound.play()
	update_healthbar()
	print("Player health: ", health)
	print("damage recieve: ", amount)
	
	if health <= 0:
		die()

func update_healthbar():
	health_bar.text = "" + str(round(health))

func die():
	is_dead = true
	can_move = false
	can_jump = false
	velocity = Vector3.ZERO
	health_bar.text = "Press Y to Respawn"
	print("Player Died!!!")

func respawn():
	if not is_my_character:  # Only the owning player can respawn themselves
		return
		
	is_dead = false
	health = 100
	global_position = spawn_position
	print("Spawn Point Global Postion: ", global_position)
	can_move = true
	can_jump = true
	update_healthbar()
	print("Player Respawned!!!")

func rotate_look(rot_input : Vector2):
	# Only rotate for local player
	if not is_my_character:
		return
		
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	if not is_my_character:
		return
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	if not is_my_character:
		return
	collider.disabled = false
	freeflying = false

func capture_mouse():
	if not is_my_character:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	if not is_my_character:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false

# Keep this only if you're NOT using MultiplayerSynchronizer
# If using MultiplayerSynchronizer, comment this out
@rpc("unreliable")
func SyncPosition(p):
	if not is_multiplayer_authority():  # Only accept position updates for non-authoritative nodes
		global_position = p
