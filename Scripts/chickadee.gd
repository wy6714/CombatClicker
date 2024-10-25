extends Node2D

var health: int = 20 # Health of the enemy
var exp: int = 34

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var enemyManager = get_node("/root/Main/EnemyManager")
@onready var anim = $Area2D/AnimatedSprite2D
@onready var healthBar = $HealthBar
@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@export var animComboCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	healthBar.init_health(health)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On mouse click...
		player.totalClicks += 1 #Track totalClicks
		player.determineDamage()
		takeDamage(player.damage)
		player.score += player.damage #Gain points based on how many points you get each click
		player.maxScore += player.damage #Increment the maximum
		updateScore()
		defeatEnemy()

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
		player.gainExp(exp)
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
	

