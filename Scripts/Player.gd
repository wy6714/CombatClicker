extends Node2D

@export var strength: int = 1
@export var critRate: float = 5
@export var critDamage: int = 2
@export var crit: bool = false # Tracking IF we crit
@export var damage: int = 0
@export var score: int = 0 #Our current score (also currency)
@export var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
@export var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this

@export var level: int = 1
@export var currentExp: int = 0
@export var expToNextLevel: int = 100
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem") # Get a reference to the levelSystem

@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@onready var anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")
@onready var chargeMeter
@onready var chargeMeterInstance
@export var animComboCount: int = 0
@export var chargeLevel = 0
@export var maxCharge = 100
@export var chargeDuration = 1.5
@export var charging: bool = false
@export var startingClaymoreAttack: bool = false

var currentEnemy;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	claymoreCharging(_delta)

func determineDamage():
	damage = strength
	var rng = randf_range(1, 100)
	if(rng <= critRate):
		crit = true
		damage = damage * critDamage

func gainExp(exp):
	currentExp += exp;
	levelUp()
	expBarSystem.expBar.value = currentExp

func levelUp():
	if(currentExp >= expToNextLevel):
		print("levelled up!")
		level += 1
		expBarSystem.levelText.text = "Lv: " + str(level)
		var expOverflow = currentExp - expToNextLevel
		currentExp = 0
		currentExp += expOverflow
		print("POST LEVEL EXP: ", currentExp)
		
		#Update strength text upon level...?
		#strength += 1
		#var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
		#strengthText.text = str(strength) 
		#critRate += 1
		#crit rate text upgdate
		#var critText = get_node("/root/Main/Scoreboard/critRateNum")
		#critText.text = str(critRate)
func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	score += damage #Gain points based on how many points you get each click
	maxScore += damage #Increment the maximum
	scoreText.text = str(score) #Update text

func dealDamage(): # DEFAULT DAMAGE DEALING. Also what swords use to deal damage
	determineDamage()
	if(currentEnemy != null):
		currentEnemy.takeDamage(damage)
	DamageNumber.display_number(damage,get_global_mouse_position(), crit) #Display damage number and attack animation upon hit
	activateAttackAnim()
	updateScore()
	crit = false
	
func claymoreCharging(_delta):
	if (startingClaymoreAttack):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) || Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# The right mouse button is pressed
			if chargeMeterInstance == null:  # Check if it's already instantiated
				print("Right mouse button is pressed")
				charging = true
				activateChargeMeter()  # Only instantiate the charge meter once
		else:
			# The right mouse button is released
			print("Right mouse button is released: CHARGE LEVEL: ", chargeLevel)
			charging = false
			determineClaymoreDamage()
			chargeLevel = 0
			if (chargeMeterInstance != null):
				chargeMeterInstance.queue_free()  # Free the charge meter when released
				chargeMeterInstance = null  # Reset the instance tracker
				startingClaymoreAttack = false
				
	if (charging):
		chargeLevel += (maxCharge / chargeDuration) * _delta
		chargeMeter.value = chargeLevel
		if (chargeLevel >= 100):
			print("RESET")
			chargeLevel = 0
	
			
func dealClaymoreDamage():
	determineDamage()
	damage = damage * 5 # Claymores should be very strong, so...
	currentEnemy.takeDamage(damage)
	DamageNumber.display_number(damage,get_global_mouse_position(), crit) #Display damage number and attack animation upon hit
	activateAttackAnim()
	crit = false
	
func activateChargeMeter():
	chargeMeterInstance = anim_claymore_meter.instantiate()
	add_child(chargeMeterInstance)

	# Print the position and scale
	print("Charge meter instance position:", chargeMeterInstance.position)
	print("Charge meter instance scale:", chargeMeterInstance.scale)

	chargeMeter = chargeMeterInstance.get_node("ChargeFill")
	if chargeMeter:
		chargeMeter.value = 0

	# Get the current global mouse position
	var mouse_pos = get_global_mouse_position()
	# Set the position slightly to the left of the mouse position
	chargeMeterInstance.position = mouse_pos - Vector2(50, 0)  # 50 pixels to the left
	print("Charge meter repositioned to:", chargeMeterInstance.position)

func determineClaymoreDamage():
	totalClicks += 1 #Track totalClicks
	if(chargeLevel >= 90):
		determineDamage()
		dealClaymoreDamage()
		score += damage #Gain points based on how much damage you get do per click
		maxScore += damage #Increment the maximum
		updateScore()
	else:
		determineDamage()
		dealDamage()
		updateScore()
	
func activateAttackAnim():
	#Later, we would put the code that determines which attack animation we use here
	# Ex: swap from sword animation to greatsword animation depending on weapon etc
	
	var attackingAnimation = attackAnim.instantiate()
	attackingAnimation.position = to_local(get_global_mouse_position())
	attackingAnimation.determineAnimation(animComboCount)
	# This combo index allows for a series of animations, a right slash, a left slash, and then a downward slash. 
	#Simply allows for a satisfying animation combo
	animComboCount += 1
	if(animComboCount >= 3):
		animComboCount = 0
	add_child(attackingAnimation)
	

