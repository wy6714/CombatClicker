extends Node2D
#Party members will act as a more robust, fleshed out, "autoclicker"

# STATS
@export var characterName: String = "Member"
@export var strength: float = 10
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 1
@export var cooldown: float = 7
@export var statusRate: float = 5
@export var ultPotency: float = 1

@export var crit: bool = false # Tracking IF we crit
@export var damage: float = 0

@export var bonusStrength: float = 0
@export var bonusCritRate: float = 0
@export var bonusCritDamage: float = 0
@export var bonusUltRegen: float = 0
@export var bonusCooldown: float = 0
@export var bonusStatusRate: float = 0
@export var bonusUltPotency: float = 0

# map element names directly to your bonus‑field names
var ULT_BUFFS = {
	"Fire":     "bonusStrength",
	"Water":    "bonusUltPotency",
	"Wind":     "bonusCritRate",
	"Earth":    "bonusCritDamage",
	"Electric": "bonusUltRegen",
}

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
@export var baseUltPotency: float = 1

@export var upgradePoints: int = 10
@export var upgradeCostMultiplier: float = 1.0
@export var totalAccumulatedUpgradePoints: int = 10
@export var upgradePointCost: int = 1000
@export var buffDuration: float = 15

# track active buff‐timers by element
var _active_buffs := {}    # element (String) → Timer

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown
@onready var partyMemberAnim = preload("res://Scenes/party_member_anims.tscn")

@onready var nameLine = $CharUI/LineEdit
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

@onready var charUI1 = $CharUI
@onready var charUI2 = $CharUI2

# Called when the node enters the scene tree for the first time.
func _ready():
	
	upgradePoints += player.totalUpgradePoints # Have party members start off with the total # of upgrade points the player has accumulated
	# through levels. This way players aren't punished for recruiting party members later (they'd start off super weak relative to everyone else)
	
	damageCooldown.wait_time = cooldown # Have them start off swinging immediately
	
	totalAccumulatedUpgradePoints = (totalAccumulatedUpgradePoints + player.level) - 1 # Their starting accumulated points are... this formula.
	
	original_position = position
	
func updateTimer():
	damageCooldown.wait_time = cooldown - bonusCooldown
	print(damageCooldown.wait_time)

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
	
func determineDamage():
	currentEnemy = player.currentEnemy
	damage = strength + bonusStrength # (Bonus from potential buff)
	var rng = randf_range(1, 100)
	if(rng <= critRate + bonusCritRate):
		crit = true
		damage = damage * (critDamage + bonusCritDamage)
		
func dealDamage(): # DEFAULT DAMAGE DEALING. Also what swords use to deal damage
	determineDamage()
	# BASIC  DAMAGE MULTIPLIER (if any, idk yet lol)
	damage = damage * 1
	if(currentEnemy != null):
		if(!currentEnemy.inQTEState): #Dont attack while in QTEs
			
			currentEnemy.takeDamage(damage, 0) # Deal damage (no break damage)
			
			randomOffsetX = randf_range(-30.0, 30.0) # Offset animation positioning (X)
			randomOffsetY = randf_range(-30.0, 30.0) # Offset animation positioning (Y)
			var randomLoc = Vector2(currentEnemy.position.x + randomOffsetX, currentEnemy.position.y + randomOffsetY) # Random loc
			playDamageAnim(randomLoc) #Now play the animation
			DamageNumber.display_number(damage,randomLoc, crit) #Display damage number and attack animation upon hit
			
			updateScore() #Update score
			ultBarSystem.updateUltProgress(ultRegen + bonusUltRegen) #Update player's ult
			if(crit):
				ultBarSystem.updateUltProgress((ultRegen + bonusUltRegen) * critDamage)
			crit = false
			
			updatePartyMemberUlt() # Gain party member ult points
			useUlt() # See if party member can use their upt
			determineStatusEffect() # See if status was applied, and determine which status

func playDamageAnim(position: Vector2):
	var rng = randi() % 2	
	
	var attackInstance = partyMemberAnim.instantiate()
	add_child(attackInstance)
	
	
	if(currentEnemy != null):
		attackInstance.global_position = position + Vector2(15,15) #Offset by Vector2
	
	var memberString = "(" + nameLine.text + ")"
	attackInstance.setMemberInfo(memberString, currentElement)
	
	if(rng == 0):
		attackInstance.playPunch()
		#attackInstance.playKick()
	if(rng == 1):
		attackInstance.playKick()
		
		
func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
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
	
	if(rng >= statusRate + bonusStatusRate):
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
	var clicked = self  # the member whose button you just hit
	
	# Gray out everyone except the selected one
	for member in get_tree().get_nodes_in_group("UIMember"):
		if member != clicked:
			member.charUI1.modulate = Color.DARK_GRAY
			member.charUI2.modulate = Color.DARK_GRAY
			
	# CASE A: the menu is closed, open it
	if not statDisplay.open:
		statDisplay.visible = true
		statDisplay.statOpen()  # play opening animation
		_applyMemberToDisplay(statDisplay, clicked)
		statDisplay.open = true
		$CharUI.modulate = Color.WHITE # Make them show as white
		$CharUI2.modulate = Color.WHITE
		return
		
	# CASE B: the menu is open on the same member → close it
	if statDisplay.currentlyDisplayingMember == clicked:
		statDisplay.statClose()  # play closing animation
		statDisplay.open = false
		
		# Return to white
		for member in get_tree().get_nodes_in_group("UIMember"):
			member.charUI1.modulate = Color.WHITE
			member.charUI2.modulate = Color.WHITE
			
		return
	
	# CASE C: the menu is open but on a DIFFERENT member → just swap data
	var previousUI1 = statDisplay.currentlyDisplayingMember.charUI1
	if previousUI1:
		previousUI1.modulate = Color.DARK_GRAY
		
	var previousUI2 = statDisplay.currentlyDisplayingMember.charUI2
	if previousUI2:
		previousUI2.modulate = Color.DARK_GRAY
		
	# bring the new one forward
	$CharUI.modulate = Color.WHITE # it SHOULD make the newly selected party member show as white, but it doesnt...
	$CharUI2.modulate = Color.WHITE
	_applyMemberToDisplay(statDisplay, clicked)
	statDisplay.randomizePitch($MenuOpen)
	
	# no change to statDisplay.open, no anim
	
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
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	#If you have ult
	if(ultCharge >= ultLimit):	
		$UltFlash.play("flash")
		print("usingUlt")
		ultCharge = 0 #reset ult charge
		partyMemberProgressBar.value = ultCharge
		var amount = ultPotency + bonusUltPotency  # how much every ult gives
		# Get the buff, and apply it to whole team. Teammates are in "Buffable"
		match currentElement:
			"Fire":
				for teammate in get_tree().get_nodes_in_group("Buffable"):
					if teammate.is_in_group("Player"):
						teammate.bonusStrength += amount
					else:
						teammate.bonusStrength += amount
					teammate.buffAnim.play("buff")
					print("BONUS STRENGTH APPLICATION: ", amount)
			"Water":
				for teammate in get_tree().get_nodes_in_group("Buffable"):
					if teammate.is_in_group("Player"):
						teammate.bonusCritDamage += amount
					else:
						teammate.bonusCritDamage += amount
					teammate.buffAnim.play("buff")	
					print("BONUS STATUS RATE (?) APPLICATION: ", amount)
			"Wind":
				for teammate in get_tree().get_nodes_in_group("Buffable"):
					if teammate.is_in_group("Player"):
						teammate.bonusCritRate += amount
					else:
						teammate.bonusCritRate += amount
					teammate.buffAnim.play("buff")
					print("BONUS CRIT RATE APPLICATION: ", amount)
			"Earth":
				for teammate in get_tree().get_nodes_in_group("Buffable"):
					if teammate.is_in_group("Player"):
						teammate.bonusCritDamage += amount
					else:
						teammate.bonusCritDamage += amount
					teammate.buffAnim.play("buff")
					print("BONUS CRIT DAMAGE APPLICATION: ", amount)
			"Electric":
				for teammate in get_tree().get_nodes_in_group("Buffable"):
					if teammate.is_in_group("Player"):
						teammate.bonusUltRegen += amount
					else:
						teammate.bonusUltRegen += amount
					teammate.buffAnim.play("buff")
					print("BONUS ULT REGEN APPLICATION: ", amount)
					
			_:
				return	
			
		if(open):
			if(statDisplay.currentlyDisplayingMember.is_in_group("Player")):
				statDisplay.updateAllPlayerValues(statDisplay.currentlyDisplayingMember)
			else:
				statDisplay.updateAllValues(statDisplay.currentlyDisplayingMember)
				
			statDisplay.upgradePointText.text = "Upgrade Points " + str(statDisplay.currentlyDisplayingMember.upgradePoints)
			statDisplay.upgradePointCostText.text = str(statDisplay.currentlyDisplayingMember.upgradePointCost) + " points"
			statDisplay.updateMemberTextColors()
			statDisplay.nameText.text = statDisplay.currentlyDisplayingMember.characterName
			
		# Spawn a brand‐new timer for this buff
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = buffDuration
		add_child(t)
		# When it fires, remove precisely this amount
		t.timeout.connect(Callable(self, "_on_buff_timeout").bind(currentElement, amount))
		t.start()
		
func _on_buff_timeout(element: String, amount: float) -> void:
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	print("buff is off............")
	# remove the buff we applied earlier
	for teammate in get_tree().get_nodes_in_group("Buffable"):
		match element:
			"Fire":
				teammate.bonusStrength -= amount
			"Water":
				teammate.bonusCritDamage -= amount
			"Wind":
				teammate.bonusCritRate -= amount
			"Earth":
				teammate.bonusCritDamage -= amount
			"Electric":
				teammate.bonusUltRegen -= amount
				
	# clean up
	if _active_buffs.has(element):
		_active_buffs[element].queue_free()
		_active_buffs.erase(element)
	
	if(open):
			if(statDisplay.currentlyDisplayingMember.is_in_group("Player")):
				statDisplay.updateAllPlayerValues(statDisplay.currentlyDisplayingMember)
			else:
				statDisplay.updateAllValues(statDisplay.currentlyDisplayingMember)
				
			statDisplay.upgradePointText.text = "Upgrade Points " + str(statDisplay.currentlyDisplayingMember.upgradePoints)
			statDisplay.upgradePointCostText.text = str(statDisplay.currentlyDisplayingMember.upgradePointCost) + " points"
			statDisplay.updateMemberTextColors()
			statDisplay.nameText.text = statDisplay.currentlyDisplayingMember.characterName

func _on_line_edit_text_changed(new_text):
	characterName = new_text
	

func onHoverEnter():
	if !hoverBlocked:
		if tween: tween.kill() # cancel old tween if it's still running
		tween = create_tween()
		var target_pos = original_position + Vector2(5, -5)
		tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		$MenuHover.play()
	
func onHoverExit():
	if !hoverBlocked:
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
