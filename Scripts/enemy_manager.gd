extends Node2D

var chickadee = preload("res://Scenes/EnemyScenes/chickadee.tscn")
func _ready():
	pass

func spawnEnemy():
	print("Spawned New Enemy")
	var enemy_instance = chickadee.instantiate()  # Create an instance of the chickadee scene
	enemy_instance.position = get_viewport().get_size() / 2  # Set position to the center
	add_child(enemy_instance)  # Add the instance to the scene


