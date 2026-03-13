extends Control

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_open_world_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_temple_run_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/temple_run.tscn")
