extends Node2D

var chickadee = preload("res://Scenes/EnemyScenes/chickadee.tscn")
var chicken = preload("res://Scenes/EnemyScenes/chicken.tscn")
var ghost = preload("res://Scenes/EnemyScenes/ghost.tscn")
var slime = preload("res://Scenes/EnemyScenes/slime.tscn")

var enemyList = [chickadee, chicken, ghost, slime]
var initialInstance = true
func _ready():
	pass

func spawnEnemy():
	$EnemySpawnTimer.start()


func _on_enemy_spawn_timer_timeout():
	spawnRandomEnemy()
	
func spawnRandomEnemy():

	var rng = randi_range(0, enemyList.size() - 1)
	var enemy_instance = enemyList[rng].instantiate()
	enemy_instance.position = get_viewport().get_size() / 2
	add_child(enemy_instance)

func spawnChickadee():
	var enemy_instance = chickadee.instantiate()  # Create an instance of the chickadee scene
	enemy_instance.position = get_viewport().get_size() / 2  # Set position to the center
	add_child(enemy_instance)  # Add the instance to the scene
