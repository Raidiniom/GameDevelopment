extends Node3D

@export var platform_scenes: Array[PackedScene]
@export var platform_length: float = 4.0
@export var spawn_distance: int = 5
@export var world_speed: float = 5.0

@onready var player = $"../Player"

var spawned_platforms = []

func _ready():
	for i in range(spawn_distance):
		spawn_platform()

func _process(delta):
	move_world(delta)
	check_spawn()
	remove_old_platform()

func move_world(delta):
	for platform in spawned_platforms:
		platform.position.z += world_speed * delta

func check_spawn():
	if spawned_platforms.size() == 0:
		return
		
	var last_platform = spawned_platforms[-1]
	
	if last_platform.position.z > -platform_length:
		spawn_platform()

func spawn_platform():
	var random_scene = platform_scenes.pick_random()
	var platform = random_scene.instantiate()

	var spawn_z = 0.0
	
	if spawned_platforms.size() == 0:
		spawn_z = 0
	else:
		var last_platform = spawned_platforms[-1]
		spawn_z = last_platform.position.z - platform_length
	
	platform.position = Vector3(0, 0, spawn_z)
	add_child(platform)

	spawned_platforms.append(platform)

func remove_old_platform():
	if spawned_platforms.size() > spawn_distance:
		var old_plat = spawned_platforms.pop_front()
		old_plat.queue_free()
