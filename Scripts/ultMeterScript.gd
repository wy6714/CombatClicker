extends Control

@onready var ultProgressBar = $TextureProgressBar
@onready var ultText = $TextureProgressBar/UltText
@export var currentUltValue: float = 0.0
@export var ultMax: int = 100
@export var ultRushMax: int = 1000
@export var canUlt: bool = false
@export var canUltRush: bool = false
@export var inUltRush: bool = false

@onready var ultRushTimer = get_node("/root/Main/Scoreboard/UltRushTimer")
@onready var ultRushTimerLabel = get_node("/root/Main/Scoreboard/UltRushTimerLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	ultProgressBar.value = 0
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	
	ultRushTimer.timeout.connect(_on_ult_rush_timer_timeout)
	
func _process(delta):
	if(inUltRush):
		ultRushTimerLabel.text = str(round(ultRushTimer.time_left))

func updateUltProgress(ultRecharge):
	currentUltValue += ultRecharge
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func subtractUltProgress():
	currentUltValue -= ultMax
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func subtractUltRushProgress():
	currentUltValue -= ultRushMax
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func updateUltState():
	canUlt = currentUltValue >= ultMax
	canUltRush = currentUltValue >= ultRushMax
	
func ultRushSetup():
	inUltRush = true
	ultRushTimerLabel.show()
	ultRushTimer.start()
	turnOffUI()
	
func _on_ult_rush_timer_timeout():
	turnOnUI()
	ultRushTimer.stop()
	ultRushTimerLabel.hide()
	
func turnOffUI(): #Shut off all UI to make the break more cinematic
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		if not ui.is_in_group("Scoreboard"):
			ui.visible = false
		
func turnOnUI():
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		if(ui not in get_tree().get_nodes_in_group("DontTurnBackOn")):
			ui.visible = true
		if(ui in get_tree().get_nodes_in_group("memberData")):
			if("open" in ui):
				ui.open = false
		
	
