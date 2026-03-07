extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not OS.has_feature("mobile"):
		visible = false

#func 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
