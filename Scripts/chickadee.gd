extends Node2D

var score: int = 0 #Our current score (also currency)
var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
var pointsToGive: int = 1 #Points granted per click. This number will scale as player gets upgrades
var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this

@onready var anim = $Area2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On mouse click...
		score += pointsToGive #Gain points based on how many points you get each click
		maxScore += pointsToGive #Increment the maximum
		totalClicks += 1 #Track totalClicks
		updateScore()

func updateScore():
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	scoreText.text = str(score) #Update text
	

