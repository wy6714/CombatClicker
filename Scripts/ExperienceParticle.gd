extends Area2D

@export var exp_value: int = 10

@export var move_duration := 0.6
var target_position: Vector2

@export var move_duration_float := 0.8
var float_target_position: Vector2
var exp_bar_ref: Node

@onready var player = get_node("/root/Main/Player")
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem")

func start_float():
	float_up()

func float_up():
	
	var rng = randf_range(0.3, 0.7)
	move_duration_float = rng
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", float_target_position, move_duration_float).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "move_to_bar"))

func move_to_bar():
	print("move to bar function just called, particle is at this location: ", $".".global_position)
	var tween = create_tween()
	
	var rng = randf_range(0.4, 0.9)
	move_duration = rng
	
	tween.tween_property(self, "global_position", target_position, move_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_reach_bar"))
	
func _on_reach_bar():
	if exp_bar_ref:
		player.gainExp(exp_value)
		expBarSystem.playJiggle()
	queue_free()
