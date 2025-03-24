extends Node2D
#Party members will act as a more robust, fleshed out, "autoclicker"

# STATS
@export var strength: float = 10
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 1
@export var crit: bool = false # Tracking IF we crit
@export var damage: float = 0
@export var cooldown: float = 7

@export var baseStrength: float = 10
@export var baseCritRate: float = 5 
@export var baseCritDamage: float = 2
@export var baseUltRegen: float = 1
@export var baseCooldown: float = 7

@export var upgradePoints: int = 10
@export var upgradeCostMultiplier: float = 1.0
@export var totalAccumulatedUpgradePoints: int = 10
@export var upgradePointCost: int = 1000

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown

@onready var nameLine = $CharUI/LineEdit
var currentEnemy

var open = false
var isPlayer = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	upgradePoints += player.totalUpgradePoints # Have party members start off with the total # of upgrade points the player has accumulated
	# through levels. This way players aren't punished for recruiting party members later (they'd start off super weak relative to everyone else)
	
	damageCooldown.wait_time = cooldown # Have them start off swinging immediately
	
func updateTimer():
	damageCooldown.wait_time = cooldown
	print(damageCooldown.wait_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func determineDamage():
	currentEnemy = player.currentEnemy
	damage = strength
	var rng = randf_range(1, 100)
	if(rng <= critRate):
		crit = true
		damage = damage * critDamage
		
func dealDamage(): # DEFAULT DAMAGE DEALING. Also what swords use to deal damage
	determineDamage()
	
	# BASIC  DAMAGE MULTIPLIER (if any, idk yet lol)
	damage = damage * 1
	
	if(currentEnemy != null):
		currentEnemy.takeDamage(damage)
		DamageNumber.display_number(damage,currentEnemy.position, crit) #Display damage number and attack animation upon hit
		#activateAttackAnim()
		updateScore()
		ultBarSystem.updateUltProgress(ultRegen)
		if(crit):
			ultBarSystem.updateUltProgress(ultRegen * critDamage)
		crit = false
	
func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	player.score += damage #Gain points based on how many points you get each click
	player.maxScore += damage #Increment the maximum
	scoreText.text = str(player.score) #Update text


func _on_damage_cooldown_timeout():
	
	dealDamage()
	updateTimer()
	print("character did a thing")
	
func _on_stats_button_down():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	
	if(!open):
		statDisplay.visible = true
		statDisplay.updateAllValues(strength, critRate, critDamage, ultRegen, cooldown)
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
		
func gainUpgradePoints():
	upgradePoints += 1

		
		
