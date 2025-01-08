extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
@onready var critRateText = get_node("/root/Main/Scoreboard/critRateNum")

@export var strengthCost = 50;
@export var critRateCost = 100;

@onready var strengthButton = $"."
@onready var critRateButton = $"../Add Crit Rate"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_up(): 
	if player.score > strengthCost:
		player.score -= strengthCost
		strengthCost += strengthCost / 2
		scoreText.text = str(player.score)
		player.strength +=1
		strengthText.text = str(player.strength)
		strengthButton.text = "+1 STRENGTH (%d)" %[strengthCost]

func _on_add_crit_rate_button_up():
	if player.score > critRateCost:
		player.score -= critRateCost
		critRateCost += critRateCost / 2
		scoreText.text = str(player.score)
		player.critRate += 0.5
		critRateText.text = str(player.critRate)
		critRateButton.text = "+0.5 Crit Rate (%d)" %[critRateCost]
