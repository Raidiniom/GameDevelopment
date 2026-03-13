extends Node3D

@onready var spawnPoint: Node3D = $SpawnPoint

@export var player_character : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 1
	for i in NakamaMultiplayer.players:
		var instancedPlayer = player_character.instantiate()
		instancedPlayer.name = str(NakamaMultiplayer.players[i].name)
		
		add_child(instancedPlayer)
		
		instancedPlayer.global_position = spawnPoint.global_position
		
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_spawn_postion() -> Vector3:
	return spawnPoint.global_position
