extends Node2D

@onready var eventCircle = $EventCircle

var scaleTime = 0.0
var scaleTimeLimit = 2.0  # The time it takes to shrink
var startScale = 8.0  # Initial scale of the circle
var endScale = 0.0  # Final scale of the circle
var shrinking = true  # Control variable

var goodScaleMax = 5.4
var goodScaleMin = 3.5

var perfectScaleMax = 3.5
var perfectScaleMin = 2.0


var loop = true # Loop for debug

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shrinkEventCircle(delta)

func shrinkEventCircle(delta):
	
	if shrinking:
		scaleTime += delta
		var t = clamp(scaleTime / scaleTimeLimit, 0.0, 1.0)  # Normalize time
		eventCircle.scale = lerp(Vector2(startScale, startScale), Vector2(endScale, endScale), t)
		
		eventCircleGrade()
		# Stop shrinking once fully scaled down
		if t >= 1.0:
			if loop:
				scaleTime = 0.0 # Reset timer
				eventCircle.scale = Vector2(startScale, startScale) # Reset scale
			else:
				shrinking = false
				
func eventCircleGrade():
	if eventCircle.scale.x >= goodScaleMin and eventCircle.scale.x <= goodScaleMax:
		print("Good!")
	elif eventCircle.scale.x >= perfectScaleMin and eventCircle.scale.x <= perfectScaleMax:
		print("Perfect!")
	else:
		print("Miss!")
		
	
	
