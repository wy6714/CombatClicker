extends Control

@onready var player = get_node("/root/Main/Player")

var currentEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	currentEnemy = player.currentEnemy

# Break effect
func breakEffect():
	currentEnemy.shrinkAndDealDamage()
	
