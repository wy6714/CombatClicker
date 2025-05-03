extends Area2D

@export var exp_value: int = 10

@export var move_duration := 0.6
var target_position: Vector2

@export var move_duration_float := 0.8
var float_target_position: Vector2
var exp_bar_ref: Node

@onready var player = get_node("/root/Main/Player")
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem")
var base_y

func start_float():
	float_up()

func float_up():
	var rng = randf_range(0.3, 0.7)
	move_duration_float = rng
	# Float up,
	var tween = create_tween()
	tween.tween_property(self, "global_position", float_target_position, move_duration_float).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	# Float  for maybe a second, 
	base_y = position.y
	await start_floaty_motion(1.0)
	# Then move to bar
	move_to_bar()

func move_to_bar():
	var tween = create_tween()
	
	var rng = randf_range(0.4, 0.9)
	move_duration = rng
	
	tween.tween_property(self, "global_position", target_position, move_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_reach_bar"))
	
func start_floaty_motion(duration: float) -> void:
	var base_y = global_position.y
	var float_tween = create_tween()

	float_tween.tween_method(
		func(offset): global_position.y = base_y + offset,
		0, 5, 0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_method(
		func(offset): global_position.y = base_y + offset,
		5, -5, 0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_method(
		func(offset): global_position.y = base_y + offset,
		-5, 0, 0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(duration).timeout

func _on_reach_bar():
	if exp_bar_ref:
		player.gainExp(exp_value)
		expBarSystem.playJiggle()
	queue_free()
