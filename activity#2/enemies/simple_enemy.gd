extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var target = $"../ProtoController"

const SPEED = 2.5
const gravity = 9.8

var player_in_range = null
var attack_cooldown = 1.0
var damage = 10

func _physics_process(delta):

	nav.target_position = target.global_transform.origin

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var next_location = nav.get_next_path_position()
	var direction = (next_location - global_transform.origin).normalized()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()

func target_position(target):
	nav.target_position = target

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		start_attacking()

func _on_attack_area_body_exited(body):
	if body == player_in_range:
		player_in_range = null

func start_attacking():
	while player_in_range:
		player_in_range.apply_damage(damage)
		await get_tree().create_timer(attack_cooldown).timeout
