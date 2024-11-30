extends Node2D

var health: int = 20 # Health of the enemy
var expToGive: int = 34

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var enemyManager = get_node("/root/Main/EnemyManager")
@onready var anim = $Area2D/AnimatedSprite2D
@onready var healthBar = $HealthBar
@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@onready var anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")
@onready var chargeMeter
@onready var chargeMeterInstance
@export var animComboCount: int = 0
@export var chargeLevel = 0
@export var maxCharge = 100
@export var chargeDuration = 1.5
@export var charging: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	healthBar.init_health(health)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(charging):
		chargeLevel += (maxCharge / chargeDuration) * _delta
		chargeMeter.value = chargeLevel
		if(chargeLevel >= 100):
			print("RESET")
			chargeLevel = 0

func _on_area_2d_input_event(viewport, event, shape_idx):
	#SWORD
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On mouse click...
		player.totalClicks += 1 #Track totalClicks
		player.determineDamage()
		takeDamage(player.damage)
		player.score += player.damage #Gain points based on how many points you get each click
		player.maxScore += player.damage #Increment the maximum
		updateScore()
		defeatEnemy()
		
	#CLAYMORE (on right click)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			# The right mouse button is pressed
			print("Right mouse button is pressed")
			charging = true
			activateChargeMeter()
		else:
			# The right mouse button is released
			print("Right mouse button is released: CHARGE LEVEL: ", chargeLevel)
			_on_right_button_released()
			charging = false
			dealClaymoreDamage()
			chargeLevel = 0
			chargeMeterInstance.queue_free()

func _on_right_button_released():
	print("Triggered on right mouse button release")

func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	scoreText.text = str(player.score) #Update text


func takeDamage(damage):
	health -= damage
	DamageNumber.display_number(damage,get_global_mouse_position(),player.crit) #Display damage number and attack animation upon hit
	activateAttackAnim()
	player.crit = false
	healthBar.health = health
	#var healthText = get_node("/root/Main/Scoreboard/enemy_health_num")
	#healthText.text = str(health)
	#print(health)
	
func defeatEnemy():
	if(health <= 0):
		player.gainExp(expToGive)
		enemyManager.spawnEnemy()
		queue_free()
	
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
	
func activateChargeMeter():
	chargeMeterInstance = anim_claymore_meter.instantiate()
	add_child(chargeMeterInstance)
	chargeMeter = chargeMeterInstance.get_node("ChargeFill")
	chargeMeter.value = 0
	chargeMeter.position = to_local(get_global_mouse_position())

func dealClaymoreDamage():
	player.totalClicks += 1 #Track totalClicks
	if(chargeLevel >= 90):
		player.determineDamage()
		takeDamage(player.damage * 5)
		player.score += player.damage * 5 #Gain points based on how many points you get each click
		player.maxScore += player.damage * 5 #Increment the maximum
		updateScore()
		defeatEnemy()
	else:
		player.determineDamage()
		takeDamage(player.damage)
		player.score += player.damage #Gain points based on how many points you get each click
		player.maxScore += player.damage #Increment the maximum
		updateScore()
		defeatEnemy()
	
	
