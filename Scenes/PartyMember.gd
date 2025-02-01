extends Node2D
#Party members will act as a more robust, fleshed out, "autoclicker"

# STATS
@export var strength: int = 10
@export var critRate: float = 5
@export var critDamage: float = 2
@export var energyRecharge: float = 1
@export var crit: bool = false # Tracking IF we crit
@export var damage: int = 0
@export var cooldown: int = 7

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown
var currentEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	damageCooldown.wait_time = cooldown
	
func updateTimer():
	damageCooldown.wait_time = cooldown

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
		ultBarSystem.updateUltProgress(energyRecharge)
		if(crit):
			ultBarSystem.updateUltProgress(energyRecharge * critDamage)
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
