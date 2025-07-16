extends Node2D
#Party members will act as a more robust, fleshed out, "autoclicker"

# STATS
@export var strength: float = 10
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 90
@export var cooldown: float = 7
@export var statusRate: float = 5
@export var ultPotency: float = 10

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
@export var buffDuration: float = 10

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

@onready var partyMemberProgressBar = $PartyMemberProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	
	upgradePoints += player.totalUpgradePoints # Have party members start off with the total # of upgrade points the player has accumulated
	# through levels. This way players aren't punished for recruiting party members later (they'd start off super weak relative to everyone else)
	
	damageCooldown.wait_time = cooldown # Have them start off swinging immediately
	
func updateTimer():
	damageCooldown.wait_time = cooldown - bonusCooldown
	print(damageCooldown.wait_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
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
		if(fire):
			print("Burn")
		if(water):
			print("Dampen")
		if(wind):
			print("Dizzy")
		if(earth):
			print("Petrify")
		if(electric):
			print("Paralysis")
			

func _on_stats_button_button_down():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	
	if(!open):
		statDisplay.visible = true
		statDisplay.updateAllValues(strength, critRate, critDamage, ultRegen, cooldown, statusRate, ultPotency, currentElement)
		open = true
		statDisplay.member = $"."
		statDisplay.upgradePointText.text = "Upgrade Points " + str(statDisplay.member.upgradePoints)
		statDisplay.upgradePointCostText.text = str(statDisplay.member.upgradePointCost) + " points"
		statDisplay.updateMemberTextColors()
		print(statDisplay.nameText.text)
		print(nameLine.text)
		statDisplay.nameText.text = nameLine.text
	elif(open):
		statDisplay.visible = false
		open = false
		statDisplay.member = null
		
func updatePartyMemberUlt():
	ultCharge += (ultRegen + bonusUltRegen) * 5
	partyMemberProgressBar.value = ultCharge
	
func useUlt():
	if(ultCharge >= ultLimit):	
		
		print("usingUlt")
		ultCharge = 0 #reset ult charge
		partyMemberProgressBar.value = ultCharge
		
		var amount = ultPotency + bonusUltPotency  # how much every ult gives
		
		match currentElement:
			"Fire":
				bonusStrength += amount
				print("BONUS STRENGTH APPLICATION: ", amount)
			"Water":
				bonusStatusRate += amount
				print("BONUS STATUS RATE (?) APPLICATION: ", amount)
			"Wind":
				bonusCritRate += amount
				print("BONUS CRIT RATE APPLICATION: ", amount)
			"Earth":
				bonusCritDamage += amount
				print("BONUS CRIT DAMAGE APPLICATION: ", amount)
			"Electric":
				bonusUltRegen += amount
				print("BONUS ULT REGEN APPLICATION: ", amount)
			_:
				return	
			
		
		# These need to be applied to the whole team...
			
		# Spawn a brand‐new timer for this buff
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = buffDuration
		add_child(t)
		# When it fires, remove precisely this amount
		t.timeout.connect(Callable(self, "_on_buff_timeout").bind(currentElement, amount))
		t.start()

func _on_buff_timeout(element: String, amount: float) -> void:
	# remove the buff we applied earlier
	match element:
		"Fire":
			bonusStrength -= amount
		"Water":
			bonusStatusRate -= amount
		"Wind":
			bonusCritRate -= amount
		"Earth":
			bonusCritDamage -= amount
		"Electric":
			bonusUltRegen -= amount

	# clean up
	if _active_buffs.has(element):
		_active_buffs[element].queue_free()
		_active_buffs.erase(element)



