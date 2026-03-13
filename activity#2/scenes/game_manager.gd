extends Node3D

@export var multiplayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Login.startGame.connect(OnStartGame)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func OnStartGame():
	$Multiplayer.add_child(multiplayerScene.instantiate())
