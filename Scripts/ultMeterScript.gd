extends Control

@onready var ultProgressBar = $TextureProgressBar
@onready var ultText = $TextureProgressBar/UltText
@export var currentUltValue: float = 0.0
@export var ultMax: int = 100
@export var ultRushMax: int = 1000
@export var canUlt: bool = false
@export var canUltRush: bool = false
@export var inUltRush: bool = false
@export var canUltRushBurst: bool = false

@onready var ultRushTimer = get_node("/root/Main/Scoreboard/UltRushTimer")
@onready var ultRushTimerLabel = get_node("/root/Main/Scoreboard/UltRushTimerLabel")

@onready var player = get_node("/root/Main/Player") # Get a reference to the player

var rushAccumulatedDamage := 0.0
var damageThreshold := 100.0
var timeBonus := 1.0

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
	currentUltValue = 0
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func updateUltState():
	canUlt = currentUltValue >= ultMax
	if(!inUltRush):
		canUltRush = currentUltValue >= ultRushMax
	
	if(inUltRush):
		canUltRushBurst = currentUltValue >= ultRushMax
	
	
func ultRushSetup():
	inUltRush = true
	ultRushTimerLabel.show()
	ultRushTimer.start()
	turnOffUI()
	$QTETimer.start()
	#damageThreshold = player.strength * 500
	damageThreshold = player.strength * 150 + player.critRate * player.critDamage * 50
	print(damageThreshold)
	
	

	
# Big Move
func ultRushBurstSetup():
	print("Ult Ryush Stuph would go here. Congrats you ult rushed.")
	
	# Resetting stuff. Temporary, we dont have animation yet.
	turnOnUI()
	ultRushTimer.stop()
	ultRushTimerLabel.hide()
	inUltRush = false
	canUltRushBurst = false
	subtractUltRushProgress()
	
func increaseRushTimer(damage: int):
	rushAccumulatedDamage += damage
	
	if(rushAccumulatedDamage >= damageThreshold):
		var newTime = ultRushTimer.time_left + timeBonus
		
		ultRushTimer.stop()
		ultRushTimer.start(newTime)
		
		rushAccumulatedDamage -= damageThreshold

func increaseRushTimerQTE(value: int):
	var newTime = ultRushTimer.time_left + value	
	ultRushTimer.stop()
	ultRushTimer.start(newTime)
	
	
func _on_ult_rush_timer_timeout(): # Natural ending to ult rush timer. No ult
	turnOnUI()
	ultRushTimer.stop()
	ultRushTimerLabel.hide()
	inUltRush = false
	canUltRushBurst = false
	currentUltValue = 0.0
	
func turnOffUI(): #Shut off all UI to make the break more cinematic
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		if not ui.is_in_group("UltUI"):
			ui.visible = false
		
func turnOnUI():
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		if(ui not in get_tree().get_nodes_in_group("DontTurnBackOn")):
			ui.visible = true
		if(ui in get_tree().get_nodes_in_group("memberData")):
			if("open" in ui):
				ui.open = false
				
func spawnQTE():
	player.currentEnemy.spawnQTE(true)
		
func _on_qte_timer_timeout():
	spawnQTE()
