extends Node2D

var health: int = 100 # Health of the enemy
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

@onready var equipmentManager = get_node("/root/Main/shop/EquipmentManager")
@onready var mouseInsideRadius = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	health = health * (1 + 0.2 * (player.level - 1))
	healthBar.max_value = health
	healthBar.init_health(health)
	player.currentEnemy = self
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	
	if(mouseInsideRadius):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On left mouse click...
			equipmentManager.performWeaponAction("left")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: #On right mouse click...
			equipmentManager.performWeaponAction("right")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed: #On middle mouse click...
			player.useUlt()
			print("hi")
	

					
func takeDamage(damage):
	health -= damage
	healthBar.health = health
	defeatEnemyCheck()
	
func defeatEnemyCheck():
	if(health <= 0):
		player.gainExp(expToGive)
		player.stopDrilling("left")
		player.stopDrilling("right")
		enemyManager.spawnEnemy()
		queue_free()
		
func _on_area_2d_mouse_entered():
	print("MOUSE ENTERED")
	mouseInsideRadius = true
	
func _on_area_2d_mouse_exited():
	print("MOUSE ENTERED")
	mouseInsideRadius = false
	
	player.stopDrilling("left") #Drills tend to be able to keep drilling even when cursor isnt on the enemy, so...
	player.stopDrilling("right")
