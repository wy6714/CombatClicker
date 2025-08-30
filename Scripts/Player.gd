extends Node2D

@export var strength: int = 1
#@export var strength: int = 100 # DEBUG STRENGTH
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 1
@export var crit: bool = false # Tracking IF we crit
@export var damage: int = 0
@export var pureDamage: int = 0
@export var score: int = 0 #Our current score (also currency)
@export var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
@export var money: int = 0 
@export var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this
@export var activeHand: String = "left"

# WEAPON BONUS STATS
var leftWeaponStats = {
	"strength": 0,
	"crit_rate": 0.0,
	"crit_damage": 0.0,
	"ult_regen": 0.0
}

var rightWeaponStats = {
	"strength": 0,
	"crit_rate": 0.0,
	"crit_damage": 0.0,
	"ult_regen": 0.0
}

@export var level: int = 1
@export var currentExp: int = 0
@export var expToNextLevel: int = 100
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem") # Get a reference to the levelSystem
@onready var ultBarSystem = get_node("/root/Main/UltMeter")

@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@onready var anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")

var leftCharging = false
var rightCharging = false
var leftChargeLevel = 0
var rightChargeLevel = 0
@onready var chargeMeterLeft
@onready var chargeMeterRight
var chargeMeterInstanceLeft = null
var chargeMeterInstanceRight = null
var startingClaymoreAttackLeft: bool = false
var startingClaymoreAttackRight: bool = false

@export var animComboCount: int = 0
@export var maxCharge = 100
@export var chargeDuration = 1.5
@export var claymoreDelay = 0.1
@export var drillActive: bool = false
@export var drillEquippedLeft: bool = false
@export var drillEquippedRight: bool = false
@onready var activeDrills = {}

var swordBreakMult = 6
var drillBreakMult = 3
var claymoreBreakMult = 8
var ultBreakMult = 9

var currentEnemy;
@onready var playerStats = get_node("/root/Main/PartyMemberPlayer")

@export var totalUpgradePoints: int = 0 
@onready var damageParticles = $DamageParticles

@onready var breakQTEdamageMult = 1.0

#Number tracking successful QTE hits
@onready var rankNum = 0

# Damage Tracking Variables
var heavy_hit_threshold := 1.3 # if actual > 130% of expected
var low_threshold := 0.8
var high_threshold := 1.2
var bigHit = false
var weaponStats = {}

var ultRushDamageMultiplier = 2.0
var characterName = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	print(";")
	score = 999999
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	claymoreCharging(_delta)
		
	if(drillEquippedLeft || drillEquippedRight):
		for key in activeDrills:  # Loops through "left" and "right"
			if activeDrills[key] != null:
				activeDrills[key].position = (get_global_mouse_position())
				activeDrills[key]["animation"].position = get_global_mouse_position()
	
	if drillEquippedLeft:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !drillActive:
			drilling("left")

	if drillEquippedRight:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && !drillActive:
			drilling("right")

	# Check if left mouse button is released
	if Input.is_action_just_released("left"):
		stopDrilling("left")
	# Check if right mouse button is released
	if Input.is_action_just_released("right"):
		stopDrilling("right")
		
func determineDamage(mult):
	
	if activeHand == "left":
		weaponStats = leftWeaponStats
	else:
		weaponStats = rightWeaponStats
	
	damage = strength
	damage *= mult
	damage += weaponStats["strength"]
	
	if(ultBarSystem.inUltRush):
		damage = damage * ultRushDamageMultiplier
		ultBarSystem.increaseRushTimer(damage)
		
	pureDamage = damage # Raw damage before variation

	var variation = randf_range(low_threshold, high_threshold)
	damage *= variation

	var rng = randf_range(1, 100)
	if(currentEnemy != null && currentEnemy.dizzy == false):
		if rng <= critRate + weaponStats["crit_rate"]:
			crit = true
			damage *= (critDamage + weaponStats["crit_damage"])
			
	elif(currentEnemy != null && currentEnemy.dizzy == true):
		if rng <= critRate + weaponStats["crit_rate"] + currentEnemy.dizzyCritRateBoost: # dizzy crit rate boost
			crit = true
			damage *= (critDamage + weaponStats["crit_damage"] + currentEnemy.dizzyCritDamageBoost) # dizzy crit damage boost
			

	trackDamage(pureDamage, damage)
	statusEffect()
	
func statusEffect():
				
	for element in weaponStats["elements"]:
		var rng = randi_range(0, 100)
		if rng <= weaponStats["status_rate"]:
			match element:
				"Fire":
					print("Activate the fire stuff")
					currentEnemy.burn = true
					currentEnemy.startBurn()
					currentEnemy.burnTimer.start()
					currentEnemy.applyStatusIcon("Burn")
				"Water":
					print("Activate the water stuff")
					currentEnemy.dampen = true
					currentEnemy.dampenTimer.start()
					currentEnemy.applyStatusIcon("Dampen")
				"Earth":
					print("Activate the earth stuff")
					currentEnemy.petrify = true
					currentEnemy.petrifyTimer.start()
					currentEnemy.applyStatusIcon("Petrify")
				"Wind":
					print("Activate the wind stuff")
					currentEnemy.dizzy = true
					currentEnemy.dizzyTimer.start()
					currentEnemy.applyStatusIcon("Dizzy")
				"Electric":
					print("Activate the electric stuff")
					currentEnemy.paralysis = true
					currentEnemy.paralysisTimer.start()
					currentEnemy.applyStatusIcon("Paralysis")
				
func gainExp(exp):
	currentExp += exp;
	levelUp()
	expBarSystem.expBar.value = currentExp
	expBarSystem.playExpSE()

func levelUp():
	while currentExp >= expToNextLevel:  # Keep leveling up as long as there's enough EXP
		print("levelled up!")
		level += 1
		expBarSystem.levelText.text = "Lv: " + str(level)
		var expOverflow = currentExp - expToNextLevel
		currentExp = expOverflow  # Retain the leftover EXP
		print("POST LEVEL EXP: ", currentExp)
		playerStats.gainUpgradePoints()
		totalUpgradePoints += 1
		for node in get_tree().get_nodes_in_group("PartyMember"):
			if node.has_method("gainUpgradePoints"):  # Ensure the node has the function/variable
				node.gainUpgradePoints()
		
		
func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	score += damage #Gain points based on how many points you get each click
	maxScore += damage #Increment the maximum
	scoreText.text = str(score) #Update text
	
	var scoreAnim = get_node("/root/Main/Scoreboard/ScoreBounceAnim")
	scoreAnim.stop()
	scoreAnim.play("ScoreBounceAnim")

func updateMoney(sum):
	var moneyText = get_node("/root/Main/Scoreboard/MoneyNumber")
	money += sum
	moneyText.text = "$" + str(money)
	
	 # Record the label’s current Y so “down” is orig_y:
	var orig_y = moneyText.position.y
	var bounce_offset = 10.0
	
	# Reset position in case a previous tween left it mid‐bounce:
	moneyText.position.y = orig_y
	
	# Create a tween and chain two property‐tweens:
	var t = moneyText.create_tween()
	t.tween_property(moneyText, "position:y", orig_y - bounce_offset, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(moneyText, "position:y", orig_y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
func claymoreCharging(_delta):
	if (startingClaymoreAttackLeft):
		claymoreChargeLeft()
				
	if(startingClaymoreAttackRight):
		claymoreChargeRight()
				
	if (leftCharging):
		leftChargeLevel += (maxCharge / chargeDuration) * _delta
		chargeMeterLeft.value = leftChargeLevel
		if (leftChargeLevel >= 100):
			print("RESET")
			leftChargeLevel = 0
			
	if (rightCharging):
		rightChargeLevel += (maxCharge / chargeDuration) * _delta
		chargeMeterRight.value = rightChargeLevel
		if (rightChargeLevel >= 100):
			print("RESET")
			rightChargeLevel = 0
			
func claymoreChargeRight():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# A mouse button is pressed
			if chargeMeterInstanceRight == null:  # Check if it's already instantiated
				print("Right mouse button is pressed")
				rightCharging = true
				activateChargeMeterRight()  # Only instantiate the charge meter once
	else:
		# The right mouse button is released
		rightCharging = false
		determineClaymoreDamageRight()
		rightChargeLevel = 0
		if (chargeMeterInstanceRight != null):
			chargeMeterInstanceRight.queue_free()  # Free the charge meter when released
			chargeMeterInstanceRight = null  # Reset the instance tracker
			startingClaymoreAttackRight = false
			
func claymoreChargeLeft():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# A left button is pressed
		if chargeMeterInstanceLeft == null:  # Check if it's already instantiated
			print("Left mouse button is pressed")
			leftCharging = true
			activateChargeMeterLeft()  # Only instantiate the charge meter once
	else:
		# The left mouse button is released
		leftCharging = false
		determineClaymoreDamageLeft()
		leftChargeLevel = 0
		if (chargeMeterInstanceLeft != null):
			chargeMeterInstanceLeft.queue_free()  # Free the charge meter when released
			chargeMeterInstanceLeft = null  # Reset the instance tracker
			startingClaymoreAttackLeft = false
	
func determineClaymoreButton(hand: String):
	if(hand == "left"):
		startingClaymoreAttackLeft = true
	if(hand == "right"):
		startingClaymoreAttackRight = true
		
func dealDamage(): # DEFAULT DAMAGE DEALING. Also what swords use to deal damage
	determineDamage(5)
	
	#Multiply break damage if broken
	breakDamageMultiplier()

	if(currentEnemy != null):
		currentEnemy.takeDamage(damage, swordBreakMult)
	
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit
	
	particleEffect(200, 300, 3, 5, 0.3)
	activateAttackAnim()
	updateScore()
	ultBarSystem.updateUltProgress(ultRegen + weaponStats["ult_regen"])
	if(crit):
		ultBarSystem.updateUltProgress(ultRegen * critDamage + weaponStats["ult_regen"])
	crit = false
	bigHit = false
			
func dealClaymoreDamage(): #Max charge on claymore!! Yay!!
	
	activateAttackAnimClaymore()
	await get_tree().create_timer(claymoreDelay).timeout
	determineDamage(10)
	
	breakDamageMultiplier()
	
	currentEnemy.takeDamage(damage, claymoreBreakMult)
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

	DamageNumber.display_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit
	particleEffect(500, 700, 4, 6, 0.25)
	
	ultBarSystem.updateUltProgress(ultRegen * 5 + weaponStats["ult_regen"])
	if(crit):
		ultBarSystem.updateUltProgress((ultRegen * 5 + weaponStats["ult_regen"]) * critDamage)
	crit = false
	bigHit = false
	
func dealFlimsyClaymoreDamage(): #Messed up the claymore charge....
	determineDamage(1)
	
	breakDamageMultiplier()
	
	currentEnemy.takeDamage(damage / 10, 1)
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

	
	DamageNumber.display_number(ceili(damage / 40), damageNumPos, crit) #Display damage number and attack animation upon hit
	particleEffect(100, 200, 2, 3, 0.3)
	activateAttackAnimClaymoreFlimsy() 
	ultBarSystem.updateUltProgress(ultRegen * 5 + weaponStats["ult_regen"])
	if(crit):
		ultBarSystem.updateUltProgress((ultRegen * 5 + weaponStats["ult_regen"]) * critDamage)
	crit = false
	bigHit = false
	print("flimsy ;;")

func drillDamage(hand: String):
	determineDamage(1)
	
	breakDamageMultiplier()
	
	if currentEnemy != null:
		currentEnemy.takeDamage(damage, drillBreakMult)
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

	DamageNumber.display_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit
	particleEffectDrill(400, 800, 4, 5, 0.13)
	updateScore()
	ultBarSystem.updateUltProgress(ultRegen + weaponStats["ult_regen"])
	if crit:
		ultBarSystem.updateUltProgress(ultRegen + weaponStats["ult_regen"] * critDamage)
	crit = false
	bigHit = false
	
func activateChargeMeterLeft():
	chargeMeterInstanceLeft = anim_claymore_meter.instantiate()
	add_child(chargeMeterInstanceLeft)

	chargeMeterLeft = chargeMeterInstanceLeft.get_node("ChargeFill")
	if chargeMeterLeft:
		chargeMeterLeft.value = 0

	# Get the current global mouse position
	var mouse_pos = get_global_mouse_position()
	# Set the position slightly to the left of the mouse position
	chargeMeterInstanceLeft.position = mouse_pos - Vector2(70, -50)
	
func activateChargeMeterRight():
	chargeMeterInstanceRight = anim_claymore_meter.instantiate()
	add_child(chargeMeterInstanceRight)

	chargeMeterRight = chargeMeterInstanceRight.get_node("ChargeFill")
	if chargeMeterRight:
		chargeMeterRight.value = 0

	# Get the current global mouse position
	var mouse_pos = get_global_mouse_position()
	# Set the position slightly to the left of the mouse position
	chargeMeterInstanceRight.position = mouse_pos - Vector2(-70, -50)

func determineClaymoreDamageLeft():
	totalClicks += 1 #Track totalClicks
	if(leftChargeLevel >= 90):
		determineDamage(10)
		dealClaymoreDamage()
		score += damage #Gain points based on how much damage you get do per click
		maxScore += damage #Increment the maximum
		updateScore()
	else:
		determineDamage(1)
		dealFlimsyClaymoreDamage()
		updateScore()
		
func determineClaymoreDamageRight():
	totalClicks += 1 #Track totalClicks
	if(rightChargeLevel >= 90):
		determineDamage(10)
		dealClaymoreDamage()
		score += damage #Gain points based on how much damage you get do per click
		maxScore += damage #Increment the maximum
		updateScore()
	else:
		determineDamage(1)
		dealFlimsyClaymoreDamage()
		updateScore()
	
func trackDamage(expected: float, actual: float):
	
	var ratio = actual / expected # Calc damage ratio
	print("Ratio: ", ratio)
	if(ratio >= heavy_hit_threshold): # If damage exceeds high damage ratio (crit, damage up or something, ult)
		print("BIG HITT!!")
		bigHit = true
		

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
	
func activateAttackAnimClaymore():
	#Later, we would put the code that determines which attack animation we use here
	# Ex: swap from sword animation to greatsword animation depending on weapon etc
	
	var attackingAnimation = attackAnim.instantiate()
	attackingAnimation.position = to_local(get_global_mouse_position())
	attackingAnimation.determineAnimationClaymore(animComboCount)
	# This combo index allows for a series of animations, a right slash, a left slash, and then a downward slash. 
	#Simply allows for a satisfying animation combo
	animComboCount += 1
	if(animComboCount >= 3):
		animComboCount = 0
	add_child(attackingAnimation)
	
func activateAttackAnimClaymoreFlimsy():
	#Later, we would put the code that determines which attack animation we use here
	# Ex: swap from sword animation to greatsword animation depending on weapon etc
	
	var attackingAnimation = attackAnim.instantiate()
	attackingAnimation.position = to_local(get_global_mouse_position())
	attackingAnimation.flimsyClaymoreAnimation()
	add_child(attackingAnimation)
	
func ultAttackAnim():
	
	var attackingAnimation = attackAnim.instantiate()
	attackingAnimation.position = to_local(get_global_mouse_position())
	attackingAnimation.ultAnimation()
	add_child(attackingAnimation)
	
func useUlt():
	if(ultBarSystem.canUlt && !ultBarSystem.canUltRush):
		# Ult. (Damage of ult is called by animation)
		
		ultAttackAnim()
		ultBarSystem.updateUltProgress(0)
		if(crit):
			ultBarSystem.updateUltProgress((ultRegen * 5 + weaponStats["ult_regen"]) * critDamage)
		crit = false
		bigHit = false
		ultBarSystem.subtractUltProgress()

# Called in ult animation in attack_anim
func ultDamage():
	determineDamage(100)
	breakDamageMultiplier()
	currentEnemy.takeDamage(damage, 1)
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_big_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit	
			
func useUltRushBurst():
	if(ultBarSystem.inUltRush):
		# Ult.
		print("Ult Rush Bursted!")
		determineDamage(500)
		breakDamageMultiplier()
		#currentEnemy.takeDamage(damage, 7)
		var rngX = randi_range(-20, 10)
		var rngY = randi_range(-10, 0)
		var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

		currentEnemy.takeDamage(damage, 1)
		DamageNumber.display_big_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit
		activateAttackAnim()
		ultBarSystem.updateUltProgress(0)
		crit = false
		bigHit = false
		ultBarSystem.resetUltProgress()

func useUltRush():
	if(ultBarSystem.canUltRush && !ultBarSystem.canUltRushBurst):
		print("Rushin")
		ultBarSystem.ultRushSetup()
		ultBarSystem.subtractUltRushProgress()
	if(ultBarSystem.canUltRushBurst):
		print("ULT RUSH BURST")
		ultBarSystem.ultRushBurstSetup()
		
func breakSlash():
	determineDamage(breakQTEdamageMult)
	
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	
	currentEnemy.takeDamage(damage, 1)
	DamageNumber.display_big_number(damage, damageNumPos, crit) #Display damage number and attack animation upon hit
	crit = false
	bigHit = false
	updateScore()
	breakQTEdamageMult = 1.0
	rankNum = 0
		
func drilling(hand: String):

	if hand == "left" and drillEquippedLeft:
		return  # Left drill already equipped
	if hand == "right" and drillEquippedRight:
		return  # Right drill already equipped
	
	if hand in activeDrills and activeDrills[hand] != null:
		return  # Prevent duplicate drills for the same hand

	var drillAnimation = attackAnim.instantiate()
	drillAnimation.position = to_local(get_global_mouse_position())
	drillAnimation.drillAnimation()
	add_child(drillAnimation)

	var drillTimer = Timer.new()
	drillTimer.wait_time = $DrillTimer.wait_time
	drillTimer.one_shot = false
	drillTimer.timeout.connect(func(): drillDamage(hand))
	add_child(drillTimer)
	drillTimer.start()

	activeDrills[hand] = {"animation": drillAnimation, "timer": drillTimer}
	# Mark the corresponding hand as equipped
	if hand == "left":
		drillEquippedLeft = true
	elif hand == "right":
		drillEquippedRight = true
	
func stopDrilling(hand: String):
	if hand == "left":
		drillEquippedLeft = false  # Reset the left drill equipped state
	elif hand == "right":
		drillEquippedRight = false  # Reset the right drill equipped state

	# Stop the corresponding drill's animation and timer
	if activeDrills.has(hand):
		activeDrills[hand]["timer"].stop()
		activeDrills[hand]["animation"].queue_free()
		activeDrills.erase(hand)

func transactionScoreUpdate(value):
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	score += value
	scoreText.text = str(score)

func particleEffect(vMin, vMax, sMin, sMax, lifetime):
	damageParticles.initial_velocity_min = vMin
	damageParticles.initial_velocity_max = vMax
	damageParticles.scale_amount_min = sMin
	damageParticles.scale_amount_max = sMax
	damageParticles.position = get_global_mouse_position()
	damageParticles.lifetime = lifetime
	damageParticles.restart()
	damageParticles.emitting = true
	
func particleEffectDrill(vMin, vMax, sMin, sMax, lifetime): # This particle effect simply just doesn't reset, drills do constant damage.
	damageParticles.initial_velocity_min = vMin
	damageParticles.initial_velocity_max = vMax
	damageParticles.scale_amount_min = sMin
	damageParticles.scale_amount_max = sMax
	damageParticles.position = get_global_mouse_position()
	damageParticles.lifetime = lifetime
	damageParticles.emitting = true
	
func breakDamageMultiplier():
	if(currentEnemy.breakable):
		if(currentEnemy.broken):
			damage = floor(damage * 1.4) # Take a bit more damage when broken
		else:
			damage = max(1,floor(damage * 0.8)) #Ensures its not 0. And take a bit less damage when not broken

func setLeftWeaponBonus(weapStrength: float, weapCritRate: float, weapCritDamage: float, weapUltRegen: float, weapElements: Array, weapStatusRate: float) -> void:
	leftWeaponStats["strength"] = weapStrength
	leftWeaponStats["crit_rate"] = weapCritRate
	leftWeaponStats["crit_damage"] = weapCritDamage
	leftWeaponStats["ult_regen"] = weapUltRegen
	leftWeaponStats["elements"] = weapElements
	leftWeaponStats["status_rate"] = weapStatusRate

	print("LEFT STATS:", leftWeaponStats)


func setRightWeaponBonus(weapStrength: float, weapCritRate: float, weapCritDamage: float, weapUltRegen: float, weapElements: Array, weapStatusRate: float) -> void:
	rightWeaponStats["strength"] = weapStrength
	rightWeaponStats["crit_rate"] = weapCritRate
	rightWeaponStats["crit_damage"] = weapCritDamage
	rightWeaponStats["ult_regen"] = weapUltRegen
	rightWeaponStats["elements"] = weapElements
	rightWeaponStats["status_rate"] = weapStatusRate

	print("RIGHT STATS:", rightWeaponStats)

