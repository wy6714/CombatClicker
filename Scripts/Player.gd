extends Node2D

#@export var strength: int = 50
@export var strength: int = 5
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 50
@export var statusRate: float = 1
@export var activeHand: String = "left"

@export var crit: bool = false
@export var damage: float = 0
@export var pureDamage: float = 0
@export var score: int = 99999999999
#@export var score: int = 0
@export var maxScore: int = 0
@export var money: int = 0
@export var totalClicks: int = 0

@export var enemiesDefeated = 0

@export var chargeAttackTutorialLimit = 4
@export var hasChargeAttacked = false

@onready var chargeAttackTutorialAnim = $"../ChargeAttackTutorial"
@onready var chargeAttackGuide = $"../ChargeAttackGuide"

@export var autoAttackInterval: float = 0.2
@export var level: int = 1
@export var maxLevel: int = 9999
@export var currentExp: int = 0
@export var expToNextLevel: int = 100
@export var totalUpgradePoints: int = 0

@export var autoAttack: bool = false
@export var ultRushDamageMultiplier: float = 2.0

@export var maxCharge: float = 100.0
@export var chargeDuration: float = 0.9
@export var chargeRequired: float = 88.0
@export var chargeHoldDelay: float = 0.3
@export var claymoreDelay: float = 0.1

@export var chargeSpeedUpPerHit: float = 0.1
@export var maxChargeSpeedMult: float = 2.5

@onready var scoreNumber = get_node("/root/Main/Scoreboard/SCORE/ScoreNumber")
@onready var autoAttackTimer = $AutoAttackTimer
@onready var chargeMeterPos = $ChargeMeterPosition
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var playerStats = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")
@onready var damageParticles = $DamageParticles

var rankNum: int = 0

const attackAnim = preload("res://Scenes/attack_anim.tscn")
const flurryAttackAnim = preload("res://Scenes/flurry_attack_anim.tscn")
const anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")

var currentEnemy = null
var base_pos: Vector2 = Vector2.ZERO

var heavy_hit_threshold := 1.3
var low_threshold := 0.8
var high_threshold := 1.2
var bigHit = false

var animComboCount: int = 0
var flurryAnimComboCount: int = 0
var currentChargeLevel: float = 0.0

var chargePending := false
var chargePendingTime := 0.0
var isCharging := false
var enteredChargeMode := false

var chargeDirection: float = 1.0
var chargeSpeedMult: float = 1.0

# Combo system for charge attacks:
# Every successful charge release increases the next charged attack by +1x damage,
# until the combo is broken by a miss. This is what makes repeated successful
# charge attacks feel like they are ramping up over time.	
var chargeComboCount: int = 0
@export var chargeComboBonusPerStack: float = 0.5
@export var chargeComboMaxStacks: int = 10

var chargeMeterInstance = null
var chargeMeter = null
var chargeMeterBaseTint: Color = Color.WHITE
var chargeMeterBaseScale: Vector2 = Vector2.ONE
var chargeSuccessTween: Tween = null
var breakQTEdamageMult: float = 1.0
var breakQTEQualityScore: float = 0.0
@onready var expMultiplier = 1.0

@export var unbrokenDamageMult = 0.4
@export var brokenDamageMult = 1.3

@export_category("Break QTE System")

# ------------------------------------------------------------
# BREAK QTE QUALITY
#
# Each QTE contributes a certain amount to the final
# break-quality score.
#
# Four Perfects = 4.0 total score.
# ------------------------------------------------------------

@export var breakPerfectScore: float = 1.0
@export var breakGoodScore: float = 0.50
@export var breakMissScore: float = 0.0

# ------------------------------------------------------------
# BREAK DAMAGE MILESTONES
#
# These are percentages of the enemy's REMAINING HP.
#
# 0 perfect-equivalent score = handled separately as flat damage.
# 1.0 score = 10%
# 2.0 score = 25%
# 3.0 score = 33.3%
# 4.0 score = 50%
#
# Only a perfect 4/4 can reach the 4.0 score.
# ------------------------------------------------------------

@export var breakDamageAt1Score: float = 0.10
@export var breakDamageAt2Score: float = 0.25
@export var breakDamageAt3Score: float = 0.333
@export var breakDamageAt4Score: float = 0.50

# Damage when every QTE is missed.
@export var breakZeroScoreDamage: float = 1.0

# The maximum possible score.
# Four perfect QTEs = 4.0.
@export var breakMaxQualityScore: float = 4.0

func _ready():
	if scoreNumber:
		base_pos = scoreNumber.position
		scoreNumber.text = str(score)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Only allow charging if mouse is over the enemy
			if has_valid_enemy() and currentEnemy.mouseInsideRadius:
				chargePending = true
				chargePendingTime = 0.0
		else:
			# Released after charge started
			if isCharging:
				release_charge_attack()
				get_viewport().set_input_as_handled()
			
			# Reset charge state
			chargePending = false
			isCharging = false


func _process(delta):
	if autoAttack and autoAttackTimer.is_stopped():
		autoAttackTimer.start()
	elif not autoAttack and not autoAttackTimer.is_stopped():
		autoAttackTimer.stop()

	if chargePending:
		chargePendingTime += delta
		if chargePendingTime >= chargeHoldDelay:
			chargePending = false
			start_charge_attack()

	if isCharging:
		update_charge_attack(delta)
		
	

func should_show_charge_attack_tutorial() -> bool:
	return (
		not hasChargeAttacked
		and enemiesDefeated >= chargeAttackTutorialLimit
	)	
			
func setupChargeAttackTutorial():
	if not should_show_charge_attack_tutorial():
		chargeAttackTutorialAnim.stop()
		chargeAttackGuide.visible = false
		return

	chargeAttackGuide.visible = true
	chargeAttackTutorialAnim.play("ChargeAttackTutorial")
	
func has_valid_enemy() -> bool:
	return currentEnemy != null and is_instance_valid(currentEnemy)

# -------------------------------------------------------------------------
# DAMAGE CALCULATION
# -------------------------------------------------------------------------

func determineDamage(mult):
	# Reset crit before calculating new damage.
	crit = false

	damage = get_effective_strength()
	damage *= mult

	if ultBarSystem.inUltRush:
		damage *= ultRushDamageMultiplier

	pureDamage = damage

	var variation = randf_range(low_threshold, high_threshold)
	damage *= variation

	var rng = randf_range(1, 100)

	var effective_crit_rate = get_effective_crit_rate()
	var effective_crit_damage = get_effective_crit_damage()

	if has_valid_enemy() and currentEnemy.dizzy == false:
		if rng <= effective_crit_rate:
			crit = true
			damage *= effective_crit_damage

	elif has_valid_enemy() and currentEnemy.dizzy == true:
		if rng <= effective_crit_rate + currentEnemy.dizzyCritRateBoost:
			crit = true
			damage *= (
				effective_crit_damage
				+ currentEnemy.dizzyCritDamageBoost
			)

	trackDamage(pureDamage, damage)
	statusEffect()

func statusEffect():
	if not has_valid_enemy():
		return

	var rng = randi_range(0, 100)
	if rng <= get_effective_status_rate():
		match playerStats.currentElement:
			"Fire":
				currentEnemy.burn = true
				currentEnemy.startBurn()
				currentEnemy.burnTimer.start()
				currentEnemy.applyStatusIcon("Burn")
			"Water":
				currentEnemy.dampen = true
				currentEnemy.dampenTimer.start()
				currentEnemy.applyStatusIcon("Dampen")
			"Earth":
				currentEnemy.petrify = true
				currentEnemy.petrifyTimer.start()
				currentEnemy.applyStatusIcon("Petrify")
			"Wind":
				currentEnemy.dizzy = true
				currentEnemy.dizzyTimer.start()
				currentEnemy.applyStatusIcon("Dizzy")
			"Electric":
				currentEnemy.paralysis = true
				currentEnemy.paralysisTimer.start()
				currentEnemy.applyStatusIcon("Paralysis")


func trackDamage(expected: float, actual: float):
	if expected == 0:
		return

	var ratio = actual / expected
	if ratio >= heavy_hit_threshold:
		bigHit = true

func breakDamageMultiplier():
	if has_valid_enemy():
		if currentEnemy.breakable:
			if currentEnemy.broken:
				damage = floor(damage * brokenDamageMult)
			else:
				damage = max(1, floor(damage * unbrokenDamageMult))

# -------------------------------------------------------------------------
# NORMAL ATTACK
# -------------------------------------------------------------------------

func dealDamage():
	if not has_valid_enemy():
		return

	determineDamage(1)
	breakDamageMultiplier()

	currentEnemy.takeDamage(damage, 6)
	if crit:
		currentEnemy.playCritReaction()

	var rngX = randi_range(-30, -10)
	var rngY = randi_range(-5, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_number(ceili(damage), damageNumPos, crit)

	particleEffect(200, 300, 3, 5, 0.3)
	activateAttackAnim()
	updateScore()

	ultBarSystem.updateUltProgress(ultRegen)
	if crit:
		ultBarSystem.updateUltProgress(ultRegen * critDamage)

	crit = false
	bigHit = false

func dealFlurryDamage():
	if not has_valid_enemy():
		return

	determineDamage(1)
	breakDamageMultiplier()

	currentEnemy.takeDamage(damage, 6)
	if crit:
		currentEnemy.playCritReaction()

	var rngX = randi_range(-30, -10)
	var rngY = randi_range(-5, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_number(ceili(damage), damageNumPos, crit)

	particleEffect(200, 300, 3, 5, 0.3)
	activateFlurryAttackAnim()
	updateScore()

	ultBarSystem.updateUltProgress(ultRegen)
	if crit:
		ultBarSystem.updateUltProgress(ultRegen * critDamage)

	crit = false
	bigHit = false

# -------------------------------------------------------------------------
# CHARGE ATTACK SYSTEM
# -------------------------------------------------------------------------

func start_charge_attack():
	if isCharging:
		return

	isCharging = true
	enteredChargeMode = true
	hasChargeAttacked = true

	chargeAttackTutorialAnim.stop()
	chargeAttackGuide.visible = false

	currentChargeLevel = 0.0
	chargeDirection = 1.0
	activateChargeMeter()

func update_charge_attack(delta):
	var step = (maxCharge / chargeDuration) * chargeSpeedMult * delta
	currentChargeLevel += step * chargeDirection

	if currentChargeLevel >= maxCharge:
		currentChargeLevel = maxCharge
		chargeDirection = -1.0
	elif currentChargeLevel <= 0:
		currentChargeLevel = 0
		chargeDirection = 1.0

	if chargeMeter != null:
		chargeMeter.value = currentChargeLevel

	if chargeMeterInstance != null and chargeMeterPos != null:
		chargeMeterInstance.global_position = chargeMeterPos.global_position

	update_charge_meter_visuals()

func update_charge_meter_visuals() -> void:
	if chargeMeter == null:
		return

	if currentChargeLevel >= chargeRequired:
		chargeMeter.tint_progress = Color.WHITE
	else:
		chargeMeter.tint_progress = chargeMeterBaseTint

func play_charge_success_feedback() -> void:
	if chargeMeter == null:
		return

	chargeMeter.tint_progress = Color.WHITE

	if chargeSuccessTween != null and chargeSuccessTween.is_valid():
		chargeSuccessTween.kill()

	chargeSuccessTween = create_tween()
	chargeSuccessTween.tween_property(
		chargeMeter,
		"scale",
		chargeMeterBaseScale * 1.08,
		0.05
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	chargeSuccessTween.tween_property(
		chargeMeter,
		"scale",
		chargeMeterBaseScale,
		0.06
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func cleanup_charge_meter() -> void:
	if chargeSuccessTween != null and chargeSuccessTween.is_valid():
		chargeSuccessTween.kill()
	chargeSuccessTween = null

	if chargeMeterInstance != null:
		chargeMeterInstance.queue_free()
		chargeMeterInstance = null
		chargeMeter = null


func release_charge_attack():
	if not isCharging:
		return

	isCharging = false
	chargeDirection = 1.0

	if not has_valid_enemy():
		currentChargeLevel = 0.0
		enteredChargeMode = false
		cleanup_charge_meter()
		return

	var is_success_hit := currentChargeLevel >= chargeRequired

	if is_success_hit:
		# Visual feedback for a successful charge:
		# 1) turn the meter white
		# 2) pulse it briefly
		# 3) keep it on screen for a tiny moment before removing it
		play_charge_success_feedback()
		
		await get_tree().create_timer(0.07).timeout

		# Combo bonus:
		# Each successful charge increases the next charged attack by +1x damage
		# (capped so it does not ramp forever). This rewards chaining good releases.
		var combo_bonus: float = chargeComboCount * chargeComboBonusPerStack
		var combo_cap: int = chargeComboMaxStacks * chargeComboBonusPerStack
		if combo_bonus > combo_cap:
			combo_bonus = combo_cap

		var charge_multiplier: float = 10 + combo_bonus
		await dealChargedDamage_with_multiplier(charge_multiplier)

		# Success builds combo and slightly speeds up the next charge cycle.
		chargeComboCount = min(chargeComboCount + 1, chargeComboMaxStacks)
		chargeSpeedMult = min(chargeSpeedMult + chargeSpeedUpPerHit, maxChargeSpeedMult)

		await get_tree().create_timer(0.05).timeout
		cleanup_charge_meter()

	elif enteredChargeMode:
		# Miss breaks the combo and resets charge speed.
		chargeComboCount = 0
		chargeSpeedMult = 1.0
		await dealWeakChargeDamage()
		cleanup_charge_meter()

	currentChargeLevel = 0.0
	enteredChargeMode = false


func activateChargeMeter():
	if chargeMeterInstance != null:
		return

	chargeMeterInstance = anim_claymore_meter.instantiate()
	add_child(chargeMeterInstance)

	chargeMeter = chargeMeterInstance.get_node("ChargeFill")
	if chargeMeter != null:
		chargeMeter.value = 0
		chargeMeter.max_value = maxCharge
		chargeMeterBaseTint = chargeMeter.tint_progress
		chargeMeterBaseScale = chargeMeter.scale
		chargeMeter.tint_progress = chargeMeterBaseTint
		chargeMeter.scale = chargeMeterBaseScale

	if chargeMeterPos != null:
		chargeMeterInstance.global_position = chargeMeterPos.global_position
	else:
		chargeMeterInstance.global_position = get_global_mouse_position() + Vector2(-70, -50)


func dealChargedDamage_with_multiplier(charge_multiplier: int):
	if not has_valid_enemy():
		return

	#await get_tree().create_timer(claymoreDelay).timeout

	if not has_valid_enemy():
		return

	determineDamage(charge_multiplier)  # Calculate damage and crit FIRST
	breakDamageMultiplier()
	
	activateAttackAnimClaymore()  # NOW create animation with correct crit status

	currentEnemy.takeDamage(damage, 8)

	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_number(ceili(damage), damageNumPos, crit)

	particleEffect(500, 700, 4, 6, 0.25)

	ultBarSystem.updateUltProgress(ultRegen * 5)
	if crit:
		ultBarSystem.updateUltProgress((ultRegen * 5) * critDamage)
		currentEnemy.playChargeCritReaction()
	else:
		currentEnemy.playChargeReaction()

	updateScore()

	crit = false
	bigHit = false

func dealChargedDamage():
	await dealChargedDamage_with_multiplier(10)


func dealWeakChargeDamage():
	if not has_valid_enemy():
		return

	activateAttackAnimClaymoreFlimsy()
	await get_tree().create_timer(claymoreDelay).timeout

	if not has_valid_enemy():
		return

	determineDamage(1)
	breakDamageMultiplier()

	currentEnemy.takeDamage(damage / 10, 1)

	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_number(ceili(damage / 10), damageNumPos, crit)

	particleEffect(100, 200, 2, 3, 0.3)

	ultBarSystem.updateUltProgress(ultRegen * 5)
	if crit:
		ultBarSystem.updateUltProgress((ultRegen * 5) * critDamage)

	updateScore()

	crit = false
	bigHit = false


# -------------------------------------------------------------------------
# EXP / LEVEL
# -------------------------------------------------------------------------

func gainExp(exp):
	currentExp += exp
	levelUp()
	
	if(level >= maxLevel):
		level = maxLevel
		
	expBarSystem.expBar.value = currentExp
	expBarSystem.playExpSE()

func levelUp():
	if(level < maxLevel):
		while currentExp >= expToNextLevel and level < maxLevel:
			level += 1
			expBarSystem.levelText.text = "Lv: " + str(level)
			var expOverflow = currentExp - expToNextLevel
			currentExp = expOverflow
			
			expToNextLevel = int(100 * (1 + 0.35 * (level - 1)))  # scale requirement with level
			expBarSystem.expBar.max_value = expToNextLevel        # keep the bar's max in sync
			
			playerStats.gainUpgradePoints()
			totalUpgradePoints += 1
			expBarSystem.levelUpSE.play()
			expBarSystem.playLevelUpTextSlide()

			for node in get_tree().get_nodes_in_group("PartyMember"):
				if node.has_method("gainUpgradePoints"):
					node.gainUpgradePoints()

# -------------------------------------------------------------------------
# SCORE / MONEY
# -------------------------------------------------------------------------

func updateScore():
	score += ceili(damage)
	maxScore += ceili(damage)
	scoreNumber.text = str(score)

	if scoreNumber.has_meta("tween"):
		var old_tween = scoreNumber.get_meta("tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := create_tween()
	scoreNumber.set_meta("tween", tween)

	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(scoreNumber, "position", base_pos + Vector2(0, -8), 0.08)
	tween.tween_property(scoreNumber, "position", base_pos, 0.2)


func updateMoney(sum):
	var moneyText = get_node("/root/Main/Scoreboard/MoneyNumber")
	money += sum
	moneyText.text = "$" + str(money)

	var orig_y = moneyText.position.y
	var bounce_offset = 10.0

	moneyText.position.y = orig_y

	var t = moneyText.create_tween()
	t.tween_property(moneyText, "position:y", orig_y - bounce_offset, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(moneyText, "position:y", orig_y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func transactionScoreUpdate(value):
	var scoreText = get_node("/root/Main/Scoreboard/SCORE/ScoreNumber")
	score += value
	scoreText.text = str(score)

	if scoreText.has_meta("tween"):
		var old_tween = scoreText.get_meta("tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var tween := create_tween()
	scoreText.set_meta("tween", tween)

	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(scoreText, "position", base_pos + Vector2(0, -8), 0.08)
	tween.tween_property(scoreText, "position", base_pos, 0.2)


# -------------------------------------------------------------------------
# ULT / SPECIALS
# -------------------------------------------------------------------------

func ultAttackAnim():
	var attackingAnimation = attackAnim.instantiate()
	attackingAnimation.position = to_local(get_global_mouse_position())
	attackingAnimation.ultAnimation()
	add_child(attackingAnimation)

func useUlt():
	if ultBarSystem.canUlt and not ultBarSystem.canUltRush:
		ultAttackAnim()
		ultBarSystem.updateUltProgress(0)
		if crit:
			ultBarSystem.updateUltProgress((ultRegen * 5) * critDamage)
		crit = false
		bigHit = false
		ultBarSystem.subtractUltProgress()


func ultDamage():
	if not has_valid_enemy():
		return

	determineDamage(25)
	breakDamageMultiplier()

	var target = currentEnemy

	target.takeDamage(damage, 1)

	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)

	var damageNumPos = target.damageNumberPosition.global_position + Vector2(rngX, rngY)

	DamageNumber.display_big_number(
		ceili(damage),
		damageNumPos,
		crit
	)

	# Choose the appropriate ultimate reaction.
	if crit:
		target.playUltCritReaction()
	else:
		target.playUltReaction()

	updateScore()

	crit = false
	bigHit = false

func useUltRushBurst():
	if ultBarSystem.inUltRush and has_valid_enemy():
		determineDamage(500)
		breakDamageMultiplier()

		var rngX = randi_range(-20, 10)
		var rngY = randi_range(-10, 0)
		var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

		currentEnemy.takeDamage(damage, 1)
		DamageNumber.display_big_number(ceili(damage), damageNumPos, crit)
		activateAttackAnim()
		ultBarSystem.updateUltProgress(0)
		crit = false
		bigHit = false
		ultBarSystem.resetUltProgress()
		
func useUltRush():
	if ultBarSystem.canUltRush and not ultBarSystem.canUltRushBurst:
		ultBarSystem.ultRushSetup()
		ultBarSystem.subtractUltRushProgress()
	if ultBarSystem.canUltRushBurst:
		ultBarSystem.ultRushBurstSetup()

func breakSlash():
	if not has_valid_enemy():
		return

	# ------------------------------------------------------------
	# GET BREAK QUALITY
	# ------------------------------------------------------------

	var qualityScore: float = breakQTEQualityScore

	# Make absolutely sure the score stays within valid bounds.
	qualityScore = clamp(qualityScore, 0.0, breakMaxQualityScore)

	var remainingHealth: float = currentEnemy.health
	var breakDamage: float = breakZeroScoreDamage
	var damageFraction: float = 0.0

	# ------------------------------------------------------------
	# CALCULATE DAMAGE FROM BREAK QUALITY
	#
	# Instead of simply counting QTEs, the actual quality of each
	# QTE contributes to a continuous score.
	#
	# The milestone values are:
	#
	# 1.0 score -> 10%
	# 2.0 score -> 25%
	# 3.0 score -> 33.3%
	# 4.0 score -> 50%
	#
	# We interpolate between those milestones so Good hits still
	# meaningfully contribute.
	# ------------------------------------------------------------

	if qualityScore <= 0.0:
		# Complete failure.
		breakDamage = breakZeroScoreDamage

	elif qualityScore < 1.0:
		# Between 0 and 1 equivalent Perfect hit.
		#
		# This means one Good is weaker than one Perfect,
		# but it still contributes damage.
		damageFraction = lerp(
			0.0,
			breakDamageAt1Score,
			qualityScore
		)

		breakDamage = remainingHealth * damageFraction

	elif qualityScore < 2.0:
		# Between the 1-score and 2-score milestones.
		var t = qualityScore - 1.0

		damageFraction = lerp(
			breakDamageAt1Score,
			breakDamageAt2Score,
			t
		)

		breakDamage = remainingHealth * damageFraction

	elif qualityScore < 3.0:
		# Between the 2-score and 3-score milestones.
		var t = qualityScore - 2.0

		damageFraction = lerp(
			breakDamageAt2Score,
			breakDamageAt3Score,
			t
		)

		breakDamage = remainingHealth * damageFraction

	else:
		# Between the 3-score and 4-score milestones.
		var t = clamp(qualityScore - 3.0, 0.0, 1.0)

		damageFraction = lerp(
			breakDamageAt3Score,
			breakDamageAt4Score,
			t
		)

		breakDamage = remainingHealth * damageFraction

	# Never deal less than 1 damage.
	breakDamage = max(1.0, breakDamage)

	# Store the result in the normal damage variable so the rest
	# of your player systems know how much damage was actually dealt.
	damage = breakDamage
	pureDamage = breakDamage
	currentEnemy.updateBreakRecoveryFromQuality()
	# ------------------------------------------------------------
	# APPLY DAMAGE
	# ------------------------------------------------------------

	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = currentEnemy.damageNumberPosition.global_position + Vector2(rngX, rngY)

	currentEnemy.takeDamage(breakDamage, 1)

	DamageNumber.display_big_number(
		ceili(breakDamage),
		damageNumPos,
		false
	)

	updateScore()

	# ------------------------------------------------------------
	# RESET ATTACK STATE
	# ------------------------------------------------------------

	crit = false
	bigHit = false
	currentChargeLevel = 0.0

	# Reset the break quality so it cannot accidentally carry into
	# another break sequence.
	breakQTEQualityScore = 0.0

# -------------------------------------------------------------------------
# ATTACK ANIMATIONS
# -------------------------------------------------------------------------

func activateAttackAnim():
	var attackingAnimation = attackAnim.instantiate()

	if not autoAttack or not has_valid_enemy():
		attackingAnimation.position = to_local(get_global_mouse_position())
	else:
		attackingAnimation.position = currentEnemy.position

	# Set attack type, then always play normal animations
	if crit:
		attackingAnimation.attack_type = "crit"
	else:
		attackingAnimation.attack_type = "normal"

	attackingAnimation.determineAnimation(animComboCount)

	animComboCount += 1
	if animComboCount >= 3:
		animComboCount = 0

	add_child(attackingAnimation)
	
func activateFlurryAttackAnim():
	var attackingAnimation = flurryAttackAnim.instantiate()

	if not autoAttack or not has_valid_enemy():
		attackingAnimation.position = to_local(get_global_mouse_position())
	else:
		attackingAnimation.position = currentEnemy.position

	if crit:
		attackingAnimation.attack_type = "crit"
	else:
		attackingAnimation.attack_type = "normal"

	attackingAnimation.determineAnimation(flurryAnimComboCount)

	flurryAnimComboCount += 1
	if flurryAnimComboCount >= 3:
		flurryAnimComboCount = 0

	add_child(attackingAnimation)

func activateAttackAnimClaymore():
	var attackingAnimation = attackAnim.instantiate()
	
	if has_valid_enemy() and currentEnemy.mouseInsideRadius:
		attackingAnimation.position = to_local(get_global_mouse_position())
	elif has_valid_enemy():
		attackingAnimation.position = to_local(currentEnemy.global_position)
	
	# Set attack type based on crit status
	if crit:
		attackingAnimation.attack_type = "charged_crit"
	else:
		attackingAnimation.attack_type = "charged"
	
	attackingAnimation.determineAnimationClaymore(animComboCount)

	animComboCount += 1
	if animComboCount >= 3:
		animComboCount = 0

	add_child(attackingAnimation)

func activateAttackAnimClaymoreFlimsy():
	var attackingAnimation = attackAnim.instantiate()
	
	# If mouse is still over enemy, use mouse position; otherwise use enemy center
	if has_valid_enemy() and currentEnemy.mouseInsideRadius:
		attackingAnimation.position = to_local(get_global_mouse_position())
	elif has_valid_enemy():
		attackingAnimation.position = to_local(currentEnemy.global_position)
	
	attackingAnimation.flimsyClaymoreAnimation()
	add_child(attackingAnimation)

# -------------------------------------------------------------------------
# PARTICLES
# -------------------------------------------------------------------------

func particleEffect(vMin, vMax, sMin, sMax, lifetime):
	damageParticles.initial_velocity_min = vMin
	damageParticles.initial_velocity_max = vMax
	damageParticles.scale_amount_min = sMin
	damageParticles.scale_amount_max = sMax

	if not autoAttack or not has_valid_enemy():
		damageParticles.position = get_global_mouse_position()
	else:
		damageParticles.position = currentEnemy.position

	damageParticles.lifetime = lifetime
	damageParticles.restart()
	damageParticles.emitting = true


func particleEffectDrill(vMin, vMax, sMin, sMax, lifetime):
	damageParticles.initial_velocity_min = vMin
	damageParticles.initial_velocity_max = vMax
	damageParticles.scale_amount_min = sMin
	damageParticles.scale_amount_max = sMax
	damageParticles.position = get_global_mouse_position()
	damageParticles.lifetime = lifetime
	damageParticles.emitting = true


# -------------------------------------------------------------------------
# AUTO ATTACK
# -------------------------------------------------------------------------

func autoSwingRush():
	if currentEnemy:
		dealFlurryDamage()

# -------------------------------------------------------------------------
# LEGACY STUBS
# -------------------------------------------------------------------------

func determineClaymoreButton(_hand: String):
	start_charge_attack()

func claymoreCharging(delta):
	if isCharging:
		update_charge_attack(delta)

func claymoreChargeLeft():
	start_charge_attack()

func claymoreChargeRight():
	start_charge_attack()

func determineClaymoreDamageLeft():
	release_charge_attack()

func determineClaymoreDamageRight():
	release_charge_attack()

func dealClaymoreDamage():
	await dealChargedDamage()

func dealFlimsyClaymoreDamage():
	await dealWeakChargeDamage()

func drilling(_hand: String):
	pass

func stopDrilling(_hand: String):
	pass

func performWeaponAction(_mouse_button: TextureButton):
	pass

func getWeaponType(_weapon_button: TextureButton) -> String:
	return "Unknown"

func setLeftWeaponBonus(_weapStrength: float, _weapCritRate: float, _weapCritDamage: float, _weapUltRegen: float, _weapStatusRate: float) -> void:
	pass

func setRightWeaponBonus(_weapStrength: float, _weapCritRate: float, _weapCritDamage: float, _weapUltRegen: float, _weapElements: Array, _weapStatusRate: float) -> void:
	pass
	
# EFFECTIVE STATS
# Use the stats stored on PartyMemberPlayer,
# including any active party Ultimate bonuses.

func get_effective_strength() -> float:
	return playerStats.strength + playerStats.bonusStrength


func get_effective_crit_rate() -> float:
	return playerStats.critRate + playerStats.bonusCritRate


func get_effective_crit_damage() -> float:
	return playerStats.critDamage + playerStats.bonusCritDamage


func get_effective_ult_regen() -> float:
	return playerStats.ultRegen + playerStats.bonusUltRegen


func get_effective_status_rate() -> float:
	return playerStats.statusRate + playerStats.bonusStatusRate
