extends Node2D

var speed: float = 200.0
var dash_speed: float = 600.0
var dash_time: float = 0.15
var dash_cooldown: float = 0.3

var dash_timer: float = 0.0
var cooldown_timer: float = 0.0

var last_tap_time := {}
var tap_threshold := 0.25
var dash_direction := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func check_tap(action: String, dir: Vector2):
	if Input.is_action_just_pressed(action):
		var now := Time.get_ticks_msec() / 1000.0

		if last_tap_time.has(action) and now - last_tap_time[action] <= tap_threshold and cooldown_timer <= 0:
			dash_direction = dir
			dash_timer = dash_time
			cooldown_timer = dash_cooldown
			print("DASH:", action)

		last_tap_time[action] = now


func check_double_tap():
	check_tap("ui_up", Vector2.UP)
	check_tap("ui_down", Vector2.DOWN)
	check_tap("ui_left", Vector2.LEFT)
	check_tap("ui_right", Vector2.RIGHT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown_timer = max(cooldown_timer - delta, 0)
	dash_timer = max(dash_timer - delta, 0)

	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if dash_timer > 0:
		position += dash_direction * dash_speed * delta
	else:
		position += direction * speed * delta

	check_double_tap()
