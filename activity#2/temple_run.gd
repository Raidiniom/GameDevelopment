extends Node3D

@onready var player = $Player
@onready var message_container: Label3D = $MessageContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	player.player_died.connect(_on_player_died)
	player.player_respawned.connect(_on_player_respawned)

func _on_player_died():
	message_container.text = "You Fell and Died!"

func _on_player_respawned():
	message_container.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
