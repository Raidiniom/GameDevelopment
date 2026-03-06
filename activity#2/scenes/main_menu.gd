extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _on_temple_run_button_pressed():
	#get_tree().change_scene_to_file("res://scenes/TempleRunScene.tscn")
#
#func _on_open_world_button_pressed():
	#get_tree().change_scene_to_file("res://scenes/OpenWorldScene.tscn")

func _on_open_world_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_temple_run_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/temple_run.tscn")
