extends Node

var score = 0

func addScore():
	score += 1
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	scoreText.text = str(score) #Update text
	#print(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
