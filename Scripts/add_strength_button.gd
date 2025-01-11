extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
@onready var critRateText = get_node("/root/Main/Scoreboard/critRateNum")

@export var strengthCost = 50;
@export var critRateCost = 100;

@onready var strengthButton = $"."
@onready var critRateButton = get_node("/root/Main/shop/Add Crit Rate")

@onready var swordHolder = get_node("/root/Main/shop/Sword")
@onready var claymoreHolder =  get_node("/root/Main/shop/Claymore")
@onready var drillHolder =  get_node("/root/Main/shop/Drill")

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

func _on_sword_button_down():
	toggle_visibility(swordHolder)

func _on_sword_1_button_down():
	pass # Replace with function body.

func _on_sword_2_button_down():
	pass # Replace with function body.

func _on_sword_3_button_down():
	pass # Replace with function body.
	
func _on_claymore_button_down():
	toggle_visibility(claymoreHolder)
	
func _on_claymore_1_button_down():
	pass # Replace with function body.
	
func _on_claymore_2_button_down():
	pass # Replace with function body.

func _on_claymore_3_button_down():
	pass # Replace with function body.

func _on_drill_button_down():
	toggle_visibility(drillHolder)
	
func _on_drill_1_button_down():
	pass # Replace with function body.

func _on_drill_2_button_down():
	pass # Replace with function body.

func _on_drill_3_button_down():
	pass # Replace with function body.

func toggle_visibility(weapon_node: Node):
	for child in weapon_node.get_children():
		if child.is_visible():
			child.hide()
		else:
			child.show()
