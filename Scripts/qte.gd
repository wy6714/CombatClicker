extends Node2D

@onready var eventCircle = $Visuals/QTEHolder/EventCircle
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

var goodMultAdd = 7.2
var perfectMultAdd = 11.5
var missMultAdd = 0.0


@onready var soundPlayer = $AudioStreamPlayer2D
@onready var okSE = preload("res://Audio/Sound Effect Okay.mp3")
@onready var goodSE = preload("res://Audio/Sound Effect Good!.mp3")
@onready var greatSE = preload("res://Audio/Sound Effect Great!!!.mp3")
@onready var perfectSE = preload("res://Audio/Sound Effect PERFECT!!!.mp3")
@onready var missSE = preload("res://Audio/Sound Effect Miss....mp3")

var missText = "Bruh"
var okString = "Okay"
var goodString = "Good!"
var greatString = "Great!!"
var perfectString = "PERFECT!!!"
@onready var gradeString = $Visuals/QTEHolder/gradeString

@onready var break_effect = get_node("/root/Main/BreakEffect")

# Called when the node enters the scene tree for the first time.
func _ready():
	scaleTimeLimit = randf_range(0.7, 1.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shrinkEventCircle(delta)
	
	if(qte != null && player != null and is_instance_valid(player.currentEnemy)):
		if(player.currentEnemy.qtePressedCount >= 4 - 1): # There are 4 spawned QTE's. SO, check for when the 3rd one is activated
			final = true

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
				player.currentEnemy.qtePressedCount += 1
				manageRankNum()
				soundPlayer.stream = missSE
				soundPlayer.play()
				if(final):
					finalQTESetup()
				
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
	
func manageRankNum():
	if(perfect):
		if(player.rankNum < 4 && player.rankNum >= 0):
			player.rankNum += 1
		if(player.rankNum <= -1):
			player.rankNum += 2
	if(miss):
		if(player.rankNum > -1):
			player.rankNum -= 1
	if(good):
		if(player.rankNum <= -1):
			player.rankNum += 2
	
	determineRank()
		
func determineRank():
	if(player.rankNum <= -1):
		print("Empty")
		print(player.rankNum)
		gradeString.text = missText
		soundPlayer.stream = missSE
		
	elif (miss):
		print("Miss...")
		print(player.rankNum)
		gradeString.text = missText
		soundPlayer.stream = missSE
		
	elif(player.rankNum == 1 || player.rankNum == 0):
		print("Okay")
		print(player.rankNum)
		soundPlayer.stream = okSE  # Set the sound to "Okay"
		gradeString.text = okString

	elif(player.rankNum == 2):
		print("Good!")
		print(player.rankNum)
		soundPlayer.stream = goodSE  # Set the sound to "Good!"
		gradeString.text = goodString

	elif(player.rankNum == 3):
		print("Great!")
		print(player.rankNum)
		soundPlayer.stream = greatSE  # Set the sound to "Great!"
		gradeString.text = greatString

	elif(player.rankNum >= 4):
		print("Perfect!!!!")
		print(player.rankNum)
		soundPlayer.stream = perfectSE  # Set the sound to "Perfect!!!"
		gradeString.text = perfectString
	
	soundPlayer.play()  # Play the sound
	
func _on_texture_button_button_down():
	if(!pressed): # Only press once
		if(miss):
			print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
			shrinking = false
			player.breakQTEdamageMult += missMultAdd
		elif(good):
			print("GOOD! Play 'Okay' animation, play SE,  and fade out the circle")
			shrinking = false
			player.breakQTEdamageMult += goodMultAdd
		else:
			print("PERFECT!!!!!! Play 'Perfect' animation, play SE, and fade out circle")
			shrinking = false
			player.breakQTEdamageMult += perfectMultAdd
		
		if(final):
			finalQTESetup()
			
		pressed = true
		player.currentEnemy.qtePressedCount += 1
		manageRankNum()
		
		anim.play("FadeOut")
		$BounceAnim.play("bounce")

# Called on animation "Fade In" which plays on autoload. Allows QTE circle to start shrinking.
func startShrinking():
	shrinking = true

# Called on animation "Fade In" which plays on autoload. Plays a Sound Effect (SE)
func playSpawnSE():
	pass

# Play the initial explosion, which then calls finalQTEEffects once it is done...exploding.
func finalQTESetup():
	break_effect.playExplosion1()
		
