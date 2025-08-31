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
var currentQTE

@onready var shaderMaterial = get_node("/root/Main/scrollingBackground/TextureRect")

# UI THAT I WISH TO MOVE DURING ULT RUSH ANIMATION #

# We already have the ult meter progress bar reference
var ultMeterPos
var ultMeterRushPos = Vector2(440, 0)

@onready var expMeter = get_node("/root/Main/ExpBarSystem")
var expMeterPos
var expMeterRushPos = Vector2(790, -88)

@onready var moneyLabel = get_node("/root/Main/Scoreboard/MoneyNumber")
var moneyPos
var moneyRushPos = Vector2(801, 80)

@onready var captureIcon = get_node("/root/Main/CurrentMonsterIconButton")
var captureIconPos
var captureIconRushPos = Vector2(100, 570)

@onready var ultFlash = $"UseUlt!"
var initialUltRushUnlock
var initialUltRushBurstUnlock

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ultProgressBar.value = 0
	ultText.text = str(currentUltValue) + "/ " + str(ultRushMax)
	ultRushTimer.timeout.connect(_on_ult_rush_timer_timeout)
	
	ultMeterPos = ultProgressBar.position
	expMeterPos = expMeter.position
	moneyPos = moneyLabel.position
	captureIconPos = captureIcon.position
	
	ultFlash.hide()
	
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
	
func resetUltProgress():
	currentUltValue = 0
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func subtractUltRushProgress():
	currentUltValue = 0
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	updateUltState()
	
func updateUltState():
	# Can they ult?
	canUlt = currentUltValue >= ultMax
	
	# If they are in ultRush
	if(!inUltRush):
		canUltRush = currentUltValue >= ultRushMax
		if(canUltRush):
			if(!initialUltRushUnlock): #Flash and play SE, ONLY ONCE
				$UltSE.play()
				$UltBarAnimation.play("UltBarGrow")
			initialUltRushUnlock = true
	
	if(inUltRush):
		canUltRushBurst = currentUltValue >= ultRushMax
		
		if(canUltRushBurst):
			ultFlash.show()
			if(!initialUltRushBurstUnlock): #Flash and play SE, ONLY ONCE
				$ColorRect/flash.play("flash") # Flash
				$UltRushSE.play()
				$UltBarAnimation.play("UltBarGrow")
			initialUltRushBurstUnlock = true
			
		else:
			ultFlash.hide()
		
func ultRushSetup():
	inUltRush = true
	canUltRush = false
	ultRushTimerLabel.show()
	ultRushTimer.wait_time = 15
	ultRushTimer.start()
	turnOffUI()
	
	$QTETimer.start()
	$SpeedLineHolder.show() # Speedlines
	$SpeedLineHolder2.show() # Speedlines
	$ColorRect/flash.play("flash") # Flash
	$UltActivatedSE.play()
	
	ultProgressBar.position = ultMeterRushPos
	expMeter.position = expMeterRushPos
	moneyLabel.position = moneyRushPos
	captureIcon.position = captureIconRushPos
	
	shaderMaterial.material.set_shader_parameter("rushFlag", 1.0) # Make background scroll go faster
	
	damageThreshold = player.strength * 150 + player.critRate * player.critDamage * 50
	print(damageThreshold)
	player.rankNum = 0
	
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
	despawnQTE()
	
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
	$QTETimer.stop()
	$SpeedLineHolder.hide()
	$SpeedLineHolder2.hide()
	$ColorRect/flash.play("flash") # Flash
	initialUltRushUnlock = false
	initialUltRushBurstUnlock = false
	ultFlash.hide()
	
	ultProgressBar.position = ultMeterPos
	expMeter.position = expMeterPos
	moneyLabel.position = moneyPos
	captureIcon.position = captureIconPos
	
	currentUltValue = 0.0
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	
	shaderMaterial.material.set_shader_parameter("rushFlag", 0.0)
	despawnQTE()
	
func despawnQTE():
	if(currentQTE != null):
		currentQTE.queue_free()
	
func endUltRush(): #Aka they used ult
	turnOnUI()
	ultRushTimer.stop()
	ultRushTimerLabel.hide()
	inUltRush = false
	canUltRushBurst = false
	$QTETimer.stop()
	$SpeedLineHolder.hide()
	$SpeedLineHolder2.hide()
	$ColorRect/flash.play("flash") # Flash
	initialUltRushUnlock = false
	initialUltRushBurstUnlock = false
	ultFlash.hide()
	
	ultProgressBar.position = ultMeterPos
	expMeter.position = expMeterPos
	moneyLabel.position = moneyPos
	captureIcon.position = captureIconPos
	
	shaderMaterial.material.set_shader_parameter("rushFlag", 0.0)
	currentUltValue = 0.0
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	despawnQTE()
	
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
	if is_instance_valid(player.currentEnemy):
		player.currentEnemy.spawnRushQTE()
		
func _on_qte_timer_timeout():
	spawnQTE()
