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
var perfectScaleMin = 2 # Maximum for getting "PERFECT!"
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
@onready var ultSystem = get_node("/root/Main/UltMeter")

@export var rushQTE = false
var expected_key

var left = false
var right = false

@onready var currentQTEIndicator = $Visuals/QTEHolder/CurrentCircle
var is_current = false

signal qte_finished(qte_node, miss, good, perfect)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# If rush QTE, give the ultSystem access. This is for RUSH. 
	if(rushQTE):
		ultSystem.currentQTE = self
	
	# Determine if left click or right click, and display the icon. This is for BREAK
	if(!rushQTE):
		var rng = randi() % 2
		if(rng == 0):
			left = true
		else:
			right = true
		determineInputLabelIcon()
		print("Not a Rush QTE")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shrinkEventCircle(delta)
	
	if(!ultSystem.inUltRush): # Ult Rush QTEs should spawn qtes "indefinitely"
		
		for node in get_tree().get_nodes_in_group("activeQTE"): # Get rid of any qtes if not in ult rush
			if is_instance_valid(node):
				node.queue_free()
				
		if(qte != null && player != null and is_instance_valid(player.currentEnemy)): # Set 4 break qtes
			if(player.currentEnemy.qtePressedCount >= 4 - 1 && player.currentEnemy.qtePressedCount != null): # There are 4 spawned QTE's. SO, check for when the 3rd one is activated
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
			else:
				shrinking = false
				$TextureButton.disabled = true
				anim.play("FadeOut")
				if(!ultSystem.inUltRush):
					if(player.currentEnemy != null):
						player.currentEnemy.qtePressedCount += 1
				# Emit the signal so the spawner knows this QTE finished
				miss = true
				manageRankNum()
				emit_signal("qte_finished", self, miss, good, perfect)
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
		elif(player.rankNum <= -1):
			player.rankNum += 2
			
	elif(miss): # Missed, subtract a point
		if(player.rankNum > -1):
			player.rankNum -= 1
			
	if(good): #Player scored good. Help them out if their score is below 0, stay still if its good, reduce to 3 if they were previously perfect.
		if(player.rankNum <= -1):
			player.rankNum += 2
			
		elif(player.rankNum >= 4):
			player.rankNum = 3

	determineRank()
		
func determineRank():
	if(player.rankNum <= -1):
		print(player.rankNum)
		gradeString.text = missText
		soundPlayer.stream = missSE
		
	elif (miss):
		print(player.rankNum)
		gradeString.text = missText
		soundPlayer.stream = missSE
		
	elif(player.rankNum == 1 || player.rankNum == 0):
		print(player.rankNum)
		soundPlayer.stream = okSE  # Set the sound to "Okay"
		gradeString.text = okString

	elif(player.rankNum == 2):
		print(player.rankNum)
		soundPlayer.stream = goodSE  # Set the sound to "Good!"
		gradeString.text = goodString

	elif(player.rankNum == 3):
		print(player.rankNum)
		soundPlayer.stream = greatSE  # Set the sound to "Great!"
		gradeString.text = greatString

	elif(player.rankNum >= 4):
		print(player.rankNum)
		soundPlayer.stream = perfectSE  # Set the sound to "Perfect!!!"
		gradeString.text = perfectString
	
	soundPlayer.play()  # Play the sound
	
func _on_texture_button_button_down():
	if(!rushQTE):
		if(!pressed): # Only press once
			
			# Miss (wrong button)
			if right and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
				shrinking = false
				player.breakQTEdamageMult += missMultAdd
				addUltRushTime(0)
				anim.play("FadeOut")
				$BounceAnim.play("bounce")
				pressed = true
				player.currentEnemy.qtePressedCount += 1
				print("Miss...")
				gradeString.text = missText
				soundPlayer.stream = missSE
				soundPlayer.play()  # Play the sound
				if(final):
					finalQTESetup()
				return  # Prevent further execution
				
			# Miss (wrong button)
			if left and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
				shrinking = false
				player.breakQTEdamageMult += missMultAdd
				addUltRushTime(0)
				anim.play("FadeOut")
				$BounceAnim.play("bounce")
				pressed = true
				player.currentEnemy.qtePressedCount += 1
				gradeString.text = missText
				soundPlayer.stream = missSE
				soundPlayer.play()  # Play the sound
				if(final):
					finalQTESetup()
				return  # Prevent further execution
				
			# Miss (Too early or too late, button was clicked)
			if(miss):
				print("MISS! Play 'Miss...' animation, play SE and fade out the circle")
				shrinking = false
				player.breakQTEdamageMult += missMultAdd
				addUltRushTime(0)
			# Good (Almost perfect)
			elif(good):
				print("GOOD! Play 'Okay' animation, play SE,  and fade out the circle")
				shrinking = false
				player.breakQTEdamageMult += goodMultAdd
				addUltRushTime(0.1)
			# Perfect
			else:
				print("PERFECT!!!!!! Play 'Perfect' animation, play SE, and fade out circle")
				shrinking = false
				player.breakQTEdamageMult += perfectMultAdd
				addUltRushTime(0.3)
			
			if(final):
				finalQTESetup()
				
			pressed = true
			player.currentEnemy.qtePressedCount += 1
			manageRankNum()
			
			anim.play("FadeOut")
			$BounceAnim.play("bounce")
	
# ------------------------------------- RUSH QTE STUFF ------------------------------------		
# Rush QTE result. Grades QTE
func rushQTEResult():
	if(!pressed): # Only press once
		if(miss):
			shrinking = false
			player.breakQTEdamageMult += missMultAdd
			addUltRushTime(0)
		elif(good):
			shrinking = false
			player.breakQTEdamageMult += goodMultAdd
			addUltRushTime(0.2)
		else:
			shrinking = false
			player.breakQTEdamageMult += perfectMultAdd
			addUltRushTime(0.4)
		
		if(final):
			finalQTESetup()
			
		pressed = true
		if(player.currentEnemy != null):
			player.currentEnemy.qtePressedCount += 1
		manageRankNum()
		
		anim.play("FadeOut")
		$BounceAnim.play("bounce")
		
			# Emit the signal so the spawner knows this QTE finished
		emit_signal("qte_finished", self, miss, good, perfect)
# Setup QTE
func setup_qte():
	# Randomly select one of the 4 directions
	var keys = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
	expected_key = keys[randi() % keys.size()]
	show_key_prompt(expected_key) # Show visual prompt to player
	# How fast does the event circle shrink
	scaleTimeLimit = randf_range(0.7, 1.2)
	pressed = false
	
# Setup QTE
func setup_qte_rush():
	# Randomly select one of the 4 directions
	var keys = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
	expected_key = keys[randi() % keys.size()]
	show_key_prompt(expected_key)
	# How fast does the event circle shrink
	scaleTimeLimit = randf_range(0.7, 1.2)
	pressed = false
	# Do NOT start the countdown here — wait for begin_rush()

# Show icon
func show_key_prompt(key):
	match key:
		KEY_LEFT:
			determineInputLabelString("←")
		KEY_RIGHT:
			determineInputLabelString("→")
		KEY_UP:
			determineInputLabelString("↑")
		KEY_DOWN:
			determineInputLabelString("↓")

func set_as_current(flag: bool) -> void:
	is_current = flag
	# visual feedback: e.g. highlight or pulsing
	
	if is_current:
		currentQTEIndicator.visible = true
	else:
		currentQTEIndicator.visible = false
			
# Manage input			
func _unhandled_input(event):
	if not rushQTE:
		return

	# DO NOT react if this isn't the designated current QTE
	if not is_current:
		return

	if pressed:
		return
			
	if event is InputEventKey and event.pressed:
		var key = event.keycode
		
		# Allow arrow keys or WASD
		var correct = (
			(key == expected_key) or
			(key == KEY_A and expected_key == KEY_LEFT) or
			(key == KEY_D and expected_key == KEY_RIGHT) or
			(key == KEY_W and expected_key == KEY_UP) or
			(key == KEY_S and expected_key == KEY_DOWN)
		)
		
		if correct:
			rushQTEResult() # Grade the input
		else:
		  # they hit one of the other QTE keys → that's a miss
			miss = true
			good = false
			perfect = false
			rushQTEResult()
			
# -------------------------- END OF RUSH QTE STUFF  ------------------------------


# Called on animation "Fade In" which plays on autoload. Allows QTE circle to start shrinking.
func startShrinking():
	shrinking = true

# Called on animation "Fade In" which plays on autoload. Plays a Sound Effect (SE)
func playSpawnSE():
	pass

# Play the initial explosion, which then calls finalQTEEffects once it is done...exploding.
func finalQTESetup():
	break_effect.playExplosion1()
	
func addUltRushTime(value: float):
	if(ultSystem.inUltRush):
		ultSystem.increaseRushTimerQTE(value)
		
func determineInputLabelString(value: String):
	$Visuals/QTEHolder/InputLabelString.show()
	$Visuals/QTEHolder/InputLabelString.text = value

func determineInputLabelIcon():
	if(left):
		$Visuals/QTEHolder/InputLabelIconLeft.show()
	else:
		$Visuals/QTEHolder/InputLabelIconRight.show()
	

		
