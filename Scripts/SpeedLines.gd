extends Node2D

var scroll_speed = 700
var scroll_speed2 = 950 #Faster speed
var loop_height = 648
@onready var ultSystem = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(!ultSystem.canUltRushBurst):
		position.y -= scroll_speed * delta
		if position.y <= -loop_height:
			position.y += loop_height  # reset for looping
	else:
		position.y -= scroll_speed2 * delta
		if position.y <= -loop_height:
			position.y += loop_height  # reset for looping
		
