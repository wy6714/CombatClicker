extends Node2D

var scroll_speed = 480
var loop_height = 648

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	position.y -= scroll_speed * delta
	if position.y <= -loop_height:
		position.y += loop_height  # reset for looping
