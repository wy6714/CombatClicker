extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_up(): 
	if player.score >10:
		player.score -=10
		scoreText.text = str(player.score)
		
		player.strength +=1
		strengthText.text = str(player.strength)
		
	#pass # Replace with function body.
	print("hello world")
	
