extends Node2D

var chickadee = preload("res://Scenes/EnemyScenes/chickadee.tscn")
var chicken = preload("res://Scenes/EnemyScenes/chicken.tscn")
var ghost = preload("res://Scenes/EnemyScenes/ghost.tscn")
var slime = preload("res://Scenes/EnemyScenes/slime.tscn")
var mushroom = preload("res://Scenes/EnemyScenes/mushroom.tscn")

@onready var player = get_node("/root/Main/Player")

var enemyList = [chickadee, chicken, ghost, slime, mushroom]
var enemy_names = ["Chickadee", "Chicken", "Ghost", "Slime", "Mushroom"]

# Gamble rewards
var forceNextRadiant: int = 0  # Count of guaranteed radiant enemies
var forceNextCapture: int = 0  # Count of guaranteed capture enemies
var tempRadiantBoost: int = 0  # Temporary +5% radiant rate
var tempRadiantBoostCounter: int = 0  # How many enemies left with boost
var permanentRadiantRate: float = 0.0  # Permanent boost
var expMultiplier: float = 1.0  # Exp multiplier

var initialInstance = true
@onready var ultBarSystem = get_node("/root/Main/UltMeter")

func _ready():
	spawnChickadeeText()

func spawnEnemy():
	$EnemySpawnTimer.start()
	
func spawnEnemyUltRush():
	$EnemySpawnTimerRush.start()
	
func _on_enemy_spawn_timer_timeout():
	spawnRandomEnemy()
	
func spawnRandomEnemy():

	var rng = randi_range(0, enemyList.size() - 1)
	#rng = 0
	var enemy_instance = enemyList[rng].instantiate()
	enemy_instance.position = get_viewport().get_size() / 2
	
	if(!ultBarSystem.inUltRush):
		DialogueBox.type_message(randomEntryText(enemy_names[rng]))
		
	add_child(enemy_instance)
	player.setupChargeAttackTutorial()

# NOT BEING USED.
func spawnChickadee():
	var enemy_instance = chickadee.instantiate()  # Create an instance of the chickadee scene
	enemy_instance.position = get_viewport().get_size() / 2  # Set position to the center
	DialogueBox.type_message(randomEntryText(enemy_names[0]))
	add_child(enemy_instance)  # Add the instance to the scene
	
func spawnChickadeeText(): # For some reason, the chickadee initially spawned comes from the main scene. 
	# Spawn chickadee code doesnt even work. so im just gonna make it the dialogue
	if(!ultBarSystem.inUltRush):
		DialogueBox.type_message(randomEntryText(enemy_names[0]))
	
func randomEntryText(enemy_name: String) -> String:
	
	var templates = [
	"%s",
	]

	# Pick a random phrase
	var template = templates[randi() % templates.size()]
	return template % enemy_name
