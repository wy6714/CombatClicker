extends Node2D

var score: int = 0 #Our current score (also currency)
var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
var pointsToGive: int = 1 #Points granted per click. This number will scale as player gets upgrades
var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this
var health: int =100 # Health of the enemy

@onready var player = get_node("Player") # Get a reference to the player
@onready var enemyManager = get_node("/root/Main/EnemyManager")
@onready var anim = $Area2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On mouse click...
		totalClicks += 1 #Track totalClicks
		player.determineDamage()
		takeDamage(player.damage)
		score += player.damage #Gain points based on how many points you get each click
		maxScore += player.damage #Increment the maximum
		updateScore()
		defeatEnemy()

func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	scoreText.text = str(score) #Update text


func takeDamage(damage):
	health -= damage
	#var healthText = get_node("/root/Main/Scoreboard/enemy_health_num")
	#healthText.text = str(health)
	#print(health)
	
func defeatEnemy():
	if(health <= 0):
		enemyManager.spawnEnemy()
		queue_free()
	

