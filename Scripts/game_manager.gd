extends Node

var score = 0

func addScore():
	score += 1
	var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
	scoreText.text = str(score) #Update text
	#print(score)

