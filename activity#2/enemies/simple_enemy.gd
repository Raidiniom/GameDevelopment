extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var attack_area = $AttackArea

const SPEED = 2.5
const gravity = 9.8

var player_in_range = null
var attack_cooldown = 1.0
var damage = 10
var is_attacking = false
var target_player = null

# Sync these variables across the network
@export var health = 100
@export var is_dead = false
@export var current_state = "idle"  # idle, chasing, attacking

func _ready():
	add_to_group("enemy")
	# Only process on server
	set_multiplayer_authority(1)  # Server is usually peer 1
	
	# Connect signals
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		attack_area.body_exited.connect(_on_attack_area_body_exited)

func _physics_process(delta):
	# Only the server controls enemy behavior
	if !multiplayer.is_server():
		return
	
	if is_dead:
		return
	
	# Find closest player
	target_player = get_closest_player()
	
	if target_player:
		# Update navigation target
		nav.target_position = target_player.global_position
		
		# Check if we should attack
		if player_in_range and player_in_range == target_player:
			current_state = "attacking"
			if not is_attacking:
				start_attacking()
		else:
			current_state = "chasing"
			is_attacking = false
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# Only move if we have a target and nav is ready
	if target_player and nav.is_target_reachable() and not player_in_range:
		var next_location = nav.get_next_path_position()
		var direction = (next_location - global_position).normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Rotate to face movement direction
		if direction.length() > 0:
			look_at(global_position + direction, Vector3.UP)
	else:
		# Stop moving when attacking
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func get_closest_player():
	var closest = null
	var closest_dist = INF
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		# Check if player is valid and alive
		if player and is_instance_valid(player) and not player.is_dead:
			var dist = global_position.distance_to(player.global_position)
			if dist < closest_dist:
				closest = player
				closest_dist = dist
	
	return closest

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and multiplayer.is_server():
		player_in_range = body

func _on_attack_area_body_exited(body):
	if body == player_in_range and multiplayer.is_server():
		player_in_range = null
		is_attacking = false

func start_attacking():
	if !multiplayer.is_server() or is_attacking or not player_in_range:
		return
	
	is_attacking = true
	
	while player_in_range and is_instance_valid(player_in_range) and not player_in_range.is_dead:
		# Deal damage
		if player_in_range.has_method("apply_damage"):
			player_in_range.apply_damage(damage)
			
			# Optional: Sync attack animation to all clients
			rpc("sync_attack_animation")
		
		await get_tree().create_timer(attack_cooldown).timeout
		
		# Break if player left range
		if not player_in_range or not is_instance_valid(player_in_range):
			break
	
	is_attacking = false

@rpc("any_peer", "call_local")
func sync_attack_animation():
	# Play attack animation here
	# This will be called on all peers
	pass

# Optional: Add respawn functionality
func respawn(position: Vector3):
	if !multiplayer.is_server():
		return
	
	health = 100
	is_dead = false
	global_position = position
	show()
	rpc("sync_respawn")

@rpc("any_peer", "call_local")
func sync_respawn():
	show()
	is_dead = false

func take_damage(amount):
	if !multiplayer.is_server():
		return
	
	health -= amount
	if health <= 0:
		die()

func die():
	is_dead = true
	hide()
	# Could also play death animation
	rpc("sync_die")

@rpc("any_peer", "call_local")
func sync_die():
	hide()
	is_dead = true
