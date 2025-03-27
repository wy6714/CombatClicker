extends Node2D

@onready var eventCircle = $QTEHolder/EventCircle
@onready var anim = $AnimationPlayer
@onready var qte = $"."
@onready var player = get_node("/root/Main/Player")
var scaleTime = 0.0
var scaleTimeLimit = 2.0  # The time it takes to shrink
var startScale = 9.0  # Initial scale of the circle
var endScale = 1.9  # Final scale of the circle
var shrinking = false  # Control variable

var goodScaleMax = 5.4 # Minimum for getting "Good!"
var goodScaleMin = 3.5 # Maximum for getting "Good!"

var perfectScaleMax = 3.5 # Minimum for getting "PERFECT!"
var perfectScaleMin = 2.0 # Maximum for getting "PERFECT!"
var final = false
var loop = false # Loop for debug

# Grading parameters
var miss = true
var good = false
var perfect = false

var pressed = false # Is the button pressed?


# Called when the node enters the scene tree for the first time.
func _ready():
	scaleTimeLimit = randf_range(1.2, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shrinkEventCircle(delta)

func shrinkEventCircle(delta):
	
	if shrinking:
		scaleTime += delta
		var t = clamp(scaleTime / scaleTimeLimit, 0.0, 1.0)  # Normalize time
		eventCircle.scale = lerp(Vector2(startScale, startScale), Vector2(endScale, endScale), t)
		
		eventCircleGrade()
		
		# Stop shrinking once fully scaled down. This resembles a "Miss"
		if t >= 1.0:
			if loop:
				scaleTime = 0.0 # Reset timer
				eventCircle.scale = Vector2(startScale, startScale) # Reset scale
				print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
			else:
				shrinking = false
				print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
				$TextureButton.disabled = true
				anim.play("FadeOut")
				if(final):
					finalQTEEffects()
				
func eventCircleGrade():
	if eventCircle.scale.x >= goodScaleMin and eventCircle.scale.x <= goodScaleMax:
		good = true
		miss = false
		perfect = false
	elif eventCircle.scale.x >= perfectScaleMin and eventCircle.scale.x <= perfectScaleMax:
		good = false
		miss = false
		perfect = true
	else:
		good = false
		miss = true
		perfect = false

func _on_texture_button_button_down():
	if(!pressed): # Only press once
		if(miss):
			print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
			shrinking = false
		elif(good):
			print("GOOD! Play 'Okay' animation, play SE,  and fade out the circle")
			shrinking = false
		else:
			print("PERFECT!!!!!! Play 'Perfect' animation, play SE, and fade out circle")
			shrinking = false
		
		if(final):
			finalQTEEffects()
			
		pressed = true
		anim.play("FadeOut")
		
		
# Called on animation "Fade In" which plays on autoload. Allows QTE circle to start shrinking.
func startShrinking():
	shrinking = true

# Called on animation "Fade In" which plays on autoload. Plays a Sound Effect (SE)
func playSpawnSE():
	pass
	
func finalQTEEffects():
	print("aha hi...!")
	player.currentEnemy.endQTEState()
