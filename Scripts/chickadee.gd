extends Node2D

@export var health: int = 100 # Health of the enemy
@export var baseHealth: int = 100
@export var expToGive: int = 34
@export var scalarLevel: float = 1.0
@export var defeatPoints: int = 100
@export var moneyToGive: int = 100
@export var enemyName: String = ""
@export var enemyPassive: String = ""

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var enemyManager = get_node("/root/Main/EnemyManager")
@onready var area = $Area2D
@onready var anim = $Area2D/AnimatedSprite2D
@onready var healthBar = $Health_Bar

var breakAmount = 100
@onready var breakBar = $Health_Bar/BreakBar
var breakable = false
var broken = false
var break_recovery_time = 4.0  # Default recovery time in seconds
var break_recovery_speed = 100.0 / break_recovery_time  # Adjusts speed dynamically
var breakPrereqLevel = 1 # Level required to encounter break meter enemies. PREFERABLY set to 4, but, for debug, it is set to 1.


@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@onready var anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")
@onready var chargeMeter
@onready var chargeMeterInstance
@export var animComboCount: int = 0
@export var chargeLevel = 0
@export var maxCharge = 100
@export var chargeDuration = 1.5
@export var charging: bool = false
@export var captureRate: int = 99

@onready var equipmentManager = get_node("/root/Main/ShopUI")
@onready var mouseInsideRadius = false

@onready var defeatAnim = $DefeatAnim
@onready var defeatAnimationList = ["defeatAnim"]
@onready var damageNumberPosition = $DamageNumberPosition
@onready var canGrantExp = true


@onready var playerCapture = get_node("/root/Main/Player/PlayerMonsterList") # Get a reference to the player

# Called when the node enters the scene tree for the first time.
func _ready():
	setInvisible()
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	health = baseHealth * (1 + 0.2 * (player.level - 1))
	healthBar.max_value = health
	healthBar.init_health(health)
	
	# Determine if a monster has a break meter or not. Early game monsters shouldn't, as the player should just get used to clicking
	# with no other distractions for a while, and THEN we implement enemy gimmicks. 
	
	if(player.level >= breakPrereqLevel):
		breakable = randi() % 2 == 1  # True or False randomly
		if(breakable):
			breakable = true #This enemy WILL have a break meter. Set it up
			breakBar.visible = true
			healthBar.init_break(breakAmount)
	
	
	player.currentEnemy = self
	
	# Scalar
	scalarLevel = (1 + 0.2 * (player.level - 1))
	expToGive *= scalarLevel
	defeatPoints *= scalarLevel
	moneyToGive *= scalarLevel
	
	enemyPassive = enemyName

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if broken:
		recoveringFromBreak(_delta)

func _on_area_2d_input_event(viewport, event, shape_idx):
	
	if(mouseInsideRadius):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On left mouse click...
			equipmentManager.performWeaponAction("left")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: #On right mouse click...
			equipmentManager.performWeaponAction("right")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed: #On middle mouse click...
			player.useUlt()
			print("hi")
					
func takeDamage(damage, breakMult):
	health -= damage
	healthBar.health = health
	
	var breakTotal = ceil(damage / 4) * breakMult
	takeBreakDamage(breakTotal)
	
	defeatEnemyCheck()
	
func takeBreakDamage(breakDamage):
	if(breakable):
		if(!broken):
			breakAmount -= breakDamage
			healthBar.breakVal = breakAmount
		if(breakAmount <= 0):
			broken = true
			print("BREAK")
			
func recoveringFromBreak(delta):
	if(broken):
		breakAmount = move_toward(breakAmount, 100, break_recovery_speed * delta)
		healthBar.breakVal = breakAmount
	if(breakAmount >= 100):
		broken = false
	
func defeatEnemyCheck():
	if(health <= 0):
		if(canGrantExp):
			canGrantExp = false
			player.stopDrilling("left")
			player.stopDrilling("right")
			
			player.gainExp(expToGive)
			player.score += defeatPoints
			player.updateMoney(moneyToGive)
			monsterCapture()
			
			var defeatAnimRng = 0
			defeatAnim.play(defeatAnimationList[defeatAnimRng])
			area.visible = false
			healthBar.visible = false
		
		
func _on_area_2d_mouse_entered():
	print("MOUSE ENTERED")
	mouseInsideRadius = true
	
func _on_area_2d_mouse_exited():
	print("MOUSE ENTERED")
	mouseInsideRadius = false
	
	player.stopDrilling("left") #Drills tend to be able to keep drilling even when cursor isnt on the enemy, so...
	player.stopDrilling("right")

func defeatAnimCleanup():
	enemyManager.spawnEnemy()
	queue_free()
	
func monsterCapture():
	var captureRng = randi_range(0, 100)
	if(captureRate >= captureRng):
		playerCapture.captureMonster(enemyName, enemyPassive)

func setInvisible(): #Set the monster and their healthbar invisible at the start
	$Health_Bar.modulate.a = 0
	$Area2D.modulate.a = 0
	
	
