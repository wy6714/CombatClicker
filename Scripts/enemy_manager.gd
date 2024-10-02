extends Node2D

var chickadee = preload("res://Scenes/EnemyScenes/chickadee.tscn")
func _ready():
	pass

func spawnEnemy():
	$EnemySpawnTimer.start()


func _on_enemy_spawn_timer_timeout():
	print("Spawned New Enemy")
	var enemy_instance = chickadee.instantiate()  # Create an instance of the chickadee scene
	enemy_instance.position = get_viewport().get_size() / 2  # Set position to the center
	add_child(enemy_instance)  # Add the instance to the scene
