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

@onready var equipmentManager = get_node("/root/Main/shop/EquipmentManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	health = health * (1 + 0.2 * (player.level - 1))
	healthBar.init_health(health)
	player.currentEnemy = self
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On left mouse click...
		equipmentManager.performWeaponAction("left")
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: #On right mouse click...
		equipmentManager.performWeaponAction("right")
					

func takeDamage(damage):
	health -= damage
	healthBar.health = health
	defeatEnemyCheck()
	
func defeatEnemyCheck():
	if(health <= 0):
		player.gainExp(expToGive)
		enemyManager.spawnEnemy()
		queue_free()
		

	
