extends Node2D
#Party members will act as a more robust, fleshed out, "autoclicker"

# STATS
@export var characterName: String = "Member"
@export var strength: float = 10
@export var critRate: float = 5
@export var critDamage: float = 2
# ULT REGEN DEBUG AT 50 RN
@export var ultRegen: float = 50
@export var cooldown: float = 7
@export var statusRate: float = 5

@export var crit: bool = false # Tracking IF we crit
@export var damage: float = 0

@export var bonusStrength: float = 0
@export var bonusCritRate: float = 0
@export var bonusCritDamage: float = 0
@export var bonusUltRegen: float = 0
@export var bonusCooldown: float = 0
@export var bonusStatusRate: float = 0

@export var upgradeCost = 1000 # Points required to buy upgrade points for
@onready var upgradePointFeedbackLocation = $"+1 Upgrade Point Loc"


@export_category("Party Ultimate Buff")

@export var ultBuffDuration: float = 15.0

# Buff gained from EACH Ultimate.
@export var ultBuffStrength: float = 10.0
@export var ultBuffCritRate: float = 5.0
@export var ultBuffCritDamage: float = 1.0
@export var ultBuffUltRegen: float = 5.0
@export var ultBuffStatusRate: float = 5.0

@export var ultBuffStrengthPercent: float = 5.0
@export var ultBuffCritRatePercent: float = 3.0
@export var ultBuffCritDamagePercent: float = 1.0
@export var ultBuffUltRegenPercent: float = 2.0
@export var ultBuffStatusRatePercent: float = 3.0

# Track the exact bonuses applied to each character.
const ULT_APPLIED_STRENGTH_META := "party_ult_applied_strength"
const ULT_APPLIED_CRIT_RATE_META := "party_ult_applied_crit_rate"
const ULT_APPLIED_CRIT_DAMAGE_META := "party_ult_applied_crit_damage"
const ULT_APPLIED_ULT_REGEN_META := "party_ult_applied_ult_regen"
const ULT_APPLIED_STATUS_RATE_META := "party_ult_applied_status_rate"
const ULT_APPLIED_COOLDOWN_META := "party_ult_applied_cooldown"

# Party members only.
# bonusCooldown is subtracted from cooldown elsewhere.
@export var ultBuffCooldown: float = 0.5

const ULT_BUFF_STACK_META := "party_ult_buff_stacks"
const ULT_BUFF_ULT_COUNT_META := "party_ult_buff_ult_count"
const ULT_BUFF_TIMER_NAME := "PartyUltBuffTimer"
const MAX_ULT_BUFF_STACKS := 5
const MIN_ULT_BUFF_DURATION := 3.0
const MAX_ULT_COOLDOWN_REDUCTION: float = 0.5

var partyUltCooldownActive: bool = false
var bonusCooldownBeforePartyUlt: float = 0.0

@export var fire = false
@export var water = false
@export var wind = false
@export var earth = false
@export var electric = false
@export var currentElement = "None"
@export var memberNumber = 1

@export var baseStrength: float = 10
@export var baseCritRate: float = 5 
@export var baseCritDamage: float = 2
@export var baseUltRegen: float = 1
@export var baseCooldown: float = 7
@export var baseStatusRate: float = 5

@export var upgradePoints: int = 10
@export var upgradeCostMultiplier: float = 1.25
@export var totalAccumulatedUpgradePoints: int = 10
@export var upgradePointCost: float = 1000.0
@export var buffDuration: float = 15
const SMOOTH_SPEED := 4.0

# maximum allowed duration for an extended buff (seconds)
var MAX_BUFF_DURATION: float = 60.0

@onready var buffIcon = get_node("/root/Main/StatBuffIcons/Buff1")
@onready var ultStackLabel = buffIcon.get_node("UltStackLabel")

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown
@onready var partyMemberAnim = preload("res://Scenes/party_member_anims.tscn")


@onready var nameLine = $CharUI/LineEdit
@onready var statsButton = $CharUI2/StatsButton
var currentEnemy

var open = false
var isPlayer = false
var randomOffsetX = 0.0
var randomOffsetY = 0.0

@onready var ultCharge = 0
@onready var ultLimit = 500

@onready var partyMemberProgressBar = $CharUI2/PartyMemberProgressBar
@onready var buffAnim = $BuffLines
@onready var ultFlashAnim = $UltFlash

var original_position: Vector2
var tween: Tween
var hovering := false
@onready var poly = $CharUI2/Area2D/CollisionPolygon2D
var hoverBlocked: bool = false
var rising: bool = false
var partyMemberIsRising: bool = false

@onready var charUI1 = $CharUI
@onready var charUI2 = $CharUI2
@onready var partyMemberData = get_node("/root/Main/shop/RecruitPartyMember")
@onready var partyManager = get_node("/root/Main/PartyMemberHolder")

# Stored reference to the active rise tween, so skipArise() can jump it to
# completion early (used by the debug/player "skip cutscene" Enter key).
var ariseTween: Tween

@export var disabled: bool = false
@export var muted: bool = false
@export var animPaused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	currentEnemy = player.currentEnemy
	# make sure each StatusFill uses a fine step and sensible defaults
	var fill = buffIcon.get_node("StatusFill")
	if "step" in fill:
		fill.step = 0.01
	fill.min_value = 0
	fill.max_value = buffDuration
	fill.value = 0


	upgradePoints += player.totalUpgradePoints # Have party members start off with the total # of upgrade points the player has accumulated
	# through levels. This way players aren't punished for recruiting party members later (they'd start off super weak relative to everyone else)
	
	damageCooldown.wait_time = cooldown # Have them start off swinging immediately
	
	totalAccumulatedUpgradePoints = (totalAccumulatedUpgradePoints + player.level) - 1 # Their starting accumulated points are... this formula.
	
	# NOTE: original_position is captured here as a fallback, but it gets
	# OVERWRITTEN by PartyManager.addMember() right after this node is
	# parented in and positioned correctly. _ready() fires the instant the
	# node enters the tree — before PartyManager has had a chance to move
	# it to its real resting slot — so this initial value is almost always
	# wrong (the scene's default spawn position) and should not be relied
	# on for hover-return behavior. PartyManager re-stamps the correct
	# value immediately after placing the node.
	original_position = position
	
	print(position)
	
func updateTimer():
	if not rising and not partyMemberIsRising:
		if partyUltCooldownActive:
			damageCooldown.wait_time = cooldown - 0.5
		else:
			damageCooldown.wait_time = cooldown - bonusCooldown
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var world_pos = get_global_mouse_position()
	var local_pos = poly.to_local(world_pos)
	var inside = Geometry2D.is_point_in_polygon(local_pos, poly.polygon)

	if inside and not hovering:
		hovering = true
		onHoverEnter()
	elif not inside and hovering:
		hovering = false
		onHoverExit()
		
	manageUltBuffIcon(delta)
	checkUltBuffExpiry()

func determineDamage():
	if player.currentEnemy != null and is_instance_valid(player.currentEnemy):
		currentEnemy = player.currentEnemy

	damage = strength + bonusStrength

	var rng = randf_range(1, 100)

	if rng <= critRate + bonusCritRate:
		crit = true
		damage = damage * (critDamage + bonusCritDamage)
		
func dealDamage(): # DEFAULT DAMAGE DEALING. Also what swords use to deal damage
	
	# If this party member has been set as inactive,
	# do absolutely nothing.
	if disabled:
		return

	determineDamage()
	damage = damage * 1

	if currentEnemy != null:
		if not currentEnemy.inQTEState and not rising and not partyMemberIsRising:

			currentEnemy.takeDamage(damage, 0)

			randomOffsetX = randf_range(-30.0, 30.0)
			randomOffsetY = randf_range(-30.0, 30.0)

			var randomLoc = Vector2(
				currentEnemy.position.x + randomOffsetX,
				currentEnemy.position.y + randomOffsetY
			)
				
			# Play the visual attack unless animations are disabled.
			if not animPaused:
				playDamageAnim(randomLoc)

			# Play the attack sound unless audio is disabled.
			if not muted:
				playRandomPartyMemberAudio()

			DamageNumber.display_number(
				damage,
				randomLoc,
				crit
			)

			updateScore()

			ultBarSystem.updateUltProgress(
				ultRegen + bonusUltRegen
			)

			if crit:
				ultBarSystem.updateUltProgress(
					(ultRegen + bonusUltRegen) * critDamage
				)

			crit = false

			updatePartyMemberUlt()
			useUlt()
			determineStatusEffect()

func playDamageAnim(position: Vector2):
	var rng = randi() % 2
	var attackInstance = partyMemberAnim.instantiate()

	# Add the animation directly to the main scene.
	get_tree().current_scene.add_child(attackInstance)

	# Make sure the animation is rendered visibly.
	attackInstance.z_index = 100
	attackInstance.modulate = Color.WHITE

	if currentEnemy != null:
		attackInstance.global_position = position + Vector2(15, 15)

	var memberString = "(" + nameLine.text + ")"
	attackInstance.setMemberInfo(memberString, currentElement)

	# Tell the animation whether this specific party member
	# has their audio muted.
	attackInstance.muted = muted

	if rng == 0:
		attackInstance.playPunch()
	else:
		attackInstance.playKick()
		
		
func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/SCORE/ScoreNumber")
	player.score += damage #Gain points based on how many points you get each click
	player.maxScore += damage #Increment the maximum
	scoreText.text = str(player.score) #Update text


func _on_damage_cooldown_timeout():
	dealDamage()
	updateTimer()
	print("character did a thing")
		
func gainUpgradePoints():
	upgradePoints += 1

func determineStatusEffect():
	var rng = randi_range(0, 100)
	
	print("Current Element According to Member: ", currentElement)
	
	if(rng <= statusRate + bonusStatusRate):
		match currentElement:
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
			
func _on_stats_button_button_down():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	var clicked = self

	# Disable all party member selection controls while the stat menu is open.
	for member in get_tree().get_nodes_in_group("UIMember"):
		member.nameLine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		member.statsButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gray out everyone except the selected one
	for member in get_tree().get_nodes_in_group("UIMember"):
		if member != clicked:
			member.charUI1.modulate = Color.DARK_GRAY
			member.charUI2.modulate = Color.DARK_GRAY

	# CASE A: the menu is closed, open it
	if not statDisplay.open:
		statDisplay.visible = true
		statDisplay.statOpen()
		_applyMemberToDisplay(statDisplay, clicked)
		statDisplay.open = true
		$CharUI.modulate = Color.WHITE
		$CharUI2.modulate = Color.WHITE
		return
	
func _applyMemberToDisplay(statDisplay, member):
	statDisplay.updateAllValues(member)  
	statDisplay.member = member
	statDisplay.currentlyDisplayingMember = member
	statDisplay.upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
	statDisplay.upgradePointCostText.text = str(member.upgradePointCost) + " points"
	statDisplay.updateMemberTextColors()
	statDisplay.nameText.text = member.characterName
		
func updatePartyMemberUlt():
	ultCharge += (ultRegen + bonusUltRegen) * 5
	partyMemberProgressBar.value = ultCharge
	
func useUlt():
	if ultCharge < ultLimit:
		return

	$UltFlash.play("flash")

	# Reset this party member's Ult meter.
	ultCharge = 0
	partyMemberProgressBar.value = 0

	applyPartyUltBuff()
		

func applyPartyUltBuff():
	var main = get_node("/root/Main")

	var timer = main.get_node_or_null(ULT_BUFF_TIMER_NAME)

	var current_stacks: int = int(
		main.get_meta(ULT_BUFF_STACK_META, 0)
	)

	# Expire the previous buff cycle if its timer has ended.
	if current_stacks > 0 and timer != null and timer.is_stopped():
		expirePartyUltBuff()
		current_stacks = 0
		
		# HARD GLOBAL CAP:
	# Only five Ultimate buff stacks are allowed across the ENTIRE party.
	# This counter lives on Main, so every party member shares it.

	current_stacks = clampi(
		int(main.get_meta(ULT_BUFF_STACK_META, 0)),
		0,
		MAX_ULT_BUFF_STACKS
	)

	main.set_meta(ULT_BUFF_STACK_META, current_stacks)

	# If five stacks already exist, stop immediately.
	# No additional stats and no additional timer duration.
	if current_stacks >= MAX_ULT_BUFF_STACKS:
		buffIcon.visible = true
		ultStackLabel.visible = true
		ultStackLabel.text = str(MAX_ULT_BUFF_STACKS)

		refreshCurrentStatDisplay()
		return
		
	# Count every Ultimate used during this buff cycle.
	var total_ults: int = int(
		main.get_meta(ULT_BUFF_ULT_COUNT_META, 0)
	) + 1

	main.set_meta(ULT_BUFF_ULT_COUNT_META, total_ults)

	# Create the shared party Ultimate buff timer if needed.
	if timer == null:
		timer = Timer.new()
		timer.name = ULT_BUFF_TIMER_NAME
		timer.one_shot = true
		main.add_child(timer)

	# Only the first five Ultimates add duration.
	var duration_to_add: float = 0.0

	if total_ults <= MAX_ULT_BUFF_STACKS:
		duration_to_add = ultBuffDuration / float(total_ults)

	# Extend the timer only when this Ultimate grants duration.
	if duration_to_add > 0.0:
		var remaining_duration: float = 0.0

		if not timer.is_stopped():
			remaining_duration = timer.time_left

		var new_duration: float = min(
			remaining_duration + duration_to_add,
			MAX_BUFF_DURATION
		)

		timer.wait_time = new_duration
		timer.start()

	# Read the current number of applied stat stacks.
	current_stacks = int(
		main.get_meta(ULT_BUFF_STACK_META, 0)
	)

	# Apply one new stat-buff stack.
	current_stacks += 1
	main.set_meta(ULT_BUFF_STACK_META, current_stacks)

	for teammate in get_tree().get_nodes_in_group("Buffable"):

		# Calculate each bonus and round UP to a whole number.
		# Percentage bonuses use the recipient's regular stat.

		var strength_bonus: int = ceili(
			ultBuffStrength
			+ teammate.strength * ultBuffStrengthPercent / 100.0
		)

		var crit_rate_bonus: int = ceili(
			ultBuffCritRate
			+ teammate.critRate * ultBuffCritRatePercent / 100.0
		)

		var crit_damage_bonus: int = ceili(
			ultBuffCritDamage
			+ teammate.critDamage * ultBuffCritDamagePercent / 100.0
		)

		var ult_regen_bonus: int = ceili(
			ultBuffUltRegen
			+ teammate.ultRegen * ultBuffUltRegenPercent / 100.0
		)

		var status_rate_bonus: int = ceili(
			ultBuffStatusRate
			+ teammate.statusRate * ultBuffStatusRatePercent / 100.0
		)

		# Apply the rounded stat bonuses.
		teammate.bonusStrength += strength_bonus
		teammate.bonusCritRate += crit_rate_bonus
		teammate.bonusCritDamage += crit_damage_bonus
		teammate.bonusUltRegen += ult_regen_bonus
		teammate.bonusStatusRate += status_rate_bonus

		# Record the exact amounts applied across all stacks.
		teammate.set_meta(
			ULT_APPLIED_STRENGTH_META,
			float(teammate.get_meta(ULT_APPLIED_STRENGTH_META, 0.0))
			+ strength_bonus
		)

		teammate.set_meta(
			ULT_APPLIED_CRIT_RATE_META,
			float(teammate.get_meta(ULT_APPLIED_CRIT_RATE_META, 0.0))
			+ crit_rate_bonus
		)

		teammate.set_meta(
			ULT_APPLIED_CRIT_DAMAGE_META,
			float(teammate.get_meta(ULT_APPLIED_CRIT_DAMAGE_META, 0.0))
			+ crit_damage_bonus
		)

		teammate.set_meta(
			ULT_APPLIED_ULT_REGEN_META,
			float(teammate.get_meta(ULT_APPLIED_ULT_REGEN_META, 0.0))
			+ ult_regen_bonus
		)

		teammate.set_meta(
			ULT_APPLIED_STATUS_RATE_META,
			float(teammate.get_meta(ULT_APPLIED_STATUS_RATE_META, 0.0))
			+ status_rate_bonus
		)
		
			# Fixed Ultimate cooldown bonus. Never stacks.
		if "cooldown" in teammate and not teammate.isPlayer:
			if not teammate.partyUltCooldownActive:
				teammate.bonusCooldownBeforePartyUlt = teammate.bonusCooldown

			teammate.partyUltCooldownActive = true
			teammate.bonusCooldown = MAX_ULT_COOLDOWN_REDUCTION

			teammate.updateTimer()

	# Update the shared buff icon.
	buffIcon.visible = true
	ultStackLabel.visible = true
	ultStackLabel.text = str(current_stacks)

	refreshCurrentStatDisplay()
	
func checkUltBuffExpiry():
	var main = get_node("/root/Main")

	var current_stacks: int = int(
		main.get_meta(ULT_BUFF_STACK_META, 0)
	)

	if current_stacks <= 0:
		return

	var timer = main.get_node_or_null(ULT_BUFF_TIMER_NAME)

	if timer == null:
		return

	if not timer.is_stopped():
		return

	expirePartyUltBuff()

func expirePartyUltBuff():
	var main = get_node("/root/Main")

	# Capture the number of stacks applied.
	var current_stacks: int = int(
		main.get_meta(ULT_BUFF_STACK_META, 0)
	)

	# Reset the counters first to prevent duplicate expiration.
	main.set_meta(ULT_BUFF_STACK_META, 0)
	main.set_meta(ULT_BUFF_ULT_COUNT_META, 0)

	var timer = main.get_node_or_null(ULT_BUFF_TIMER_NAME)

	if timer != null:
		timer.stop()

	# Remove the exact accumulated bonuses recorded during this cycle.
	if current_stacks > 0:
		for teammate in get_tree().get_nodes_in_group("Buffable"):

			var strength_bonus: float = float(
				teammate.get_meta(ULT_APPLIED_STRENGTH_META, 0.0)
			)

			var crit_rate_bonus: float = float(
				teammate.get_meta(ULT_APPLIED_CRIT_RATE_META, 0.0)
			)

			var crit_damage_bonus: float = float(
				teammate.get_meta(ULT_APPLIED_CRIT_DAMAGE_META, 0.0)
			)

			var ult_regen_bonus: float = float(
				teammate.get_meta(ULT_APPLIED_ULT_REGEN_META, 0.0)
			)

			var status_rate_bonus: float = float(
				teammate.get_meta(ULT_APPLIED_STATUS_RATE_META, 0.0)
			)

			# Remove all recorded stat bonuses.
			teammate.bonusStrength -= strength_bonus
			teammate.bonusCritRate -= crit_rate_bonus
			teammate.bonusCritDamage -= crit_damage_bonus
			teammate.bonusUltRegen -= ult_regen_bonus
			teammate.bonusStatusRate -= status_rate_bonus

			# Clear the recorded stat bonuses for the next cycle.
			teammate.set_meta(ULT_APPLIED_STRENGTH_META, 0.0)
			teammate.set_meta(ULT_APPLIED_CRIT_RATE_META, 0.0)
			teammate.set_meta(ULT_APPLIED_CRIT_DAMAGE_META, 0.0)
			teammate.set_meta(ULT_APPLIED_ULT_REGEN_META, 0.0)
			teammate.set_meta(ULT_APPLIED_STATUS_RATE_META, 0.0)
			
			# Restore the previous cooldown bonus when the Ultimate buff expires.
			if "cooldown" in teammate and not teammate.isPlayer:
				teammate.bonusCooldown = teammate.bonusCooldownBeforePartyUlt
				teammate.partyUltCooldownActive = false

				teammate.updateTimer()

	# Hide the shared buff icon.
	buffIcon.visible = false
	ultStackLabel.visible = false
	ultStackLabel.text = ""

	# Reset the fill so the next buff starts from zero.
	var fill = buffIcon.get_node("StatusFill")
	fill.value = 0

	refreshCurrentStatDisplay()
	
func manageUltBuffIcon(delta):
	var main = get_node("/root/Main")

	var current_stacks: int = int(
		main.get_meta(ULT_BUFF_STACK_META, 0)
	)

	var timer = main.get_node_or_null(ULT_BUFF_TIMER_NAME)

	if current_stacks <= 0 or timer == null:
		buffIcon.visible = false
		ultStackLabel.visible = false
		ultStackLabel.text = ""
		return

	buffIcon.visible = true
	ultStackLabel.visible = true
	ultStackLabel.text = str(current_stacks)

	var fill = buffIcon.get_node("StatusFill")

	fill.min_value = 0
	fill.max_value = timer.wait_time

	var target_value = timer.wait_time - timer.time_left

	var t = clamp(delta * SMOOTH_SPEED, 0.0, 1.0)

	fill.value = lerp(
		fill.value,
		target_value,
		t
	)

func refreshCurrentStatDisplay():
	var statDisplay = get_node_or_null("/root/Main/PartyMemberStatHolderUI")

	if statDisplay == null:
		return

	if not statDisplay.open:
		return

	var displayedMember = statDisplay.currentlyDisplayingMember

	if displayedMember == null:
		return

	if displayedMember.is_in_group("Player"):
		statDisplay.updateAllPlayerValues(displayedMember)
	else:
		statDisplay.updateAllValues(displayedMember)

	statDisplay.upgradePointText.text = (
		"Upgrade Points " + str(displayedMember.upgradePoints)
	)

	statDisplay.upgradePointCostText.text = (
		str(displayedMember.upgradePointCost) + " points"
	)

	statDisplay.updateMemberTextColors()
	statDisplay.nameText.text = displayedMember.characterName

func _on_line_edit_text_changed(new_text):
	characterName = new_text

	var line_edit = $CharUI/LineEdit
	var font = line_edit.get_theme_font("font")
	
	var display_name = characterName

	if display_name.is_empty():
		display_name = "Member" + str(memberNumber)

	var shop = get_node("/root/Main/ShopUI")
	shop.updatePartyMemberName(memberNumber, display_name)

	var font_size = 24
	var minimum_size = 10
	var available_width = line_edit.size.x - 10

	while font_size > minimum_size:
		var text_width = font.get_string_size(
			new_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size
		).x

		if text_width <= available_width:
			break

		font_size -= 1

	line_edit.add_theme_font_size_override("font_size", font_size)

	# Force the LineEdit to stop scrolling to the caret.
	var old_caret = line_edit.caret_column
	line_edit.caret_column = 0
	line_edit.caret_column = old_caret

	
func arise():
	rising = true
	for member in partyManager.roster:
		if member != null and "partyMemberIsRising" in member:
			member.partyMemberIsRising = true
	
	if(currentEnemy):
		currentEnemy.animationPause()
	
	
	# PartyManager has already set position (including the correct resting
	# Y, which varies depending on where the player icon actually sits) by
	# the time arise() is called. Previously this hardcoded a rise from
	# Y=140 down to Y=0, which only worked by coincidence when members were
	# parented at scene root with a resting Y near 0 — it would actively
	# fight PartyManager's positioning once that resting Y became anything
	# else (e.g. -519 after reparenting under PartyMemberClipPanel).
	var restingY = position.y
	ariseTween = create_tween()
	ariseTween.tween_property(
		self,           # the node this script is on
		"position:y",   # animate the Y position
		restingY,        # final value: wherever PartyManager actually placed it
		11.0            # duration (seconds)
	).from(restingY + 140)        # start value: 140px below resting position
	
	await ariseTween.finished
	_finishArise()

func _finishArise():
	rising = false
	for member in partyManager.roster:
		if member != null and "partyMemberIsRising" in member:
			member.partyMemberIsRising = false
	if(currentEnemy):
		currentEnemy.animationResume()

func skipArise():
	if ariseTween and ariseTween.is_valid():
		ariseTween.kill()
		position.y = original_position.y
		_finishArise()
	
func onHoverEnter():
	if not hoverBlocked and not rising:
		if tween: tween.kill() # cancel old tween if it's still running
		tween = create_tween()
		var target_pos = original_position + Vector2(3, -5)
		tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		$MenuHover.play()
	
func onHoverExit():
	if not hoverBlocked and not rising:
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			nameLine.release_focus()

func playRandomPartyMemberAudio():
	var sounds = [
		preload("res://Audio/PartyMemberSE1.wav"),
		preload("res://Audio/PartyMemberSE2.wav"),
		preload("res://Audio/PartyMemberSE3.wav"),
		preload("res://Audio/PartyMemberSE4.wav")
	]

	$AttackSE.pitch_scale = randf_range(0.8, 1.2)
	$AttackSE.stream = sounds.pick_random()
	$AttackSE.play()
