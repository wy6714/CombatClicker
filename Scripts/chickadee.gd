extends Node2D

@export var health: int = 100 # Health of the enemy
@export var maxHealth : int = 0
@export var baseHealth: int = 100
@export var expToGive: int = 34
@export var scalarLevel: float = 1.0
@export var defeatPoints: int = 100
@export var moneyToGive: int = 100
@export var enemyName: String = ""
@export var enemyPassive: String = ""

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var enemyManager = get_node("/root/Main/EnemyManager")
@onready var area = $Area2D
@onready var anim = $Area2D/AnimatedSprite2D
@onready var healthBar = $Health_Bar
@onready var collision = $Area2D/CollisionShape2D

var breakAmount = 100
var baseBreak = 100
@onready var breakBar = $Health_Bar/BreakBar
var breakable = false
var broken = false
var recovering = false
var break_recovery_time = 4.0  # Default recovery time in seconds
var break_recovery_speed = 100.0 / break_recovery_time  # Adjusts speed dynamically
var breakPrereqLevel = 1 # Level required to encounter break meter enemies. PREFERABLY set to 4, but, for debug, it is set to 1.


@onready var attackAnim = preload("res://Scenes/attack_anim.tscn")
@onready var anim_claymore_meter = preload("res://Scenes/anim_claymore_meter.tscn")

@onready var qte = preload("res://Scenes/qte.tscn")
@onready var qteRush = preload("res://Scenes/qteRush.tscn")
@onready var qteSpawnTimer = $QTESpawnTimer
@onready var qteCurrentCounter = 0
var qteCount = 4
var inQTEState = false
var breakState = false

@onready var chargeMeter
@onready var chargeMeterInstance
@export var animComboCount: int = 0
@export var chargeLevel = 0
@export var maxCharge = 100
@export var chargeDuration = 1.5
@export var charging: bool = false
@export var captureRate: int = 99

@onready var equipmentManager = get_node("/root/Main/ShopUI")
@onready var mouseInsideRadius = false

@onready var defeatAnim = $DefeatAnim
@onready var defeatAnimationList = ["defeatAnim"]
@onready var damageNumberPosition = $DamageNumberPosition
@onready var canGrantExp = true

@onready var playerCapture = get_node("/root/Main/Player/PlayerMonsterList") # Get a reference to the player
@onready var breakScreen = get_node("/root/Main/BreakEffect")
@onready var breakScreenAnim = get_node("/root/Main/BreakEffect/AnimationPlayer")

# Define the screen bounds (Left, Top, Right, Bottom)
var leftLimit = 80
var topLimit = 80
var rightLimit = 860
var bottomLimit = 400

#Screen bounds for RUSH QTEs
var leftLimit2 = 280
var topLimit2 = 240
var rightLimit2 = 780
var bottomLimit2 = 400

var spawned_qte_positions = []  # Keeps track of where QTEs are

var original_scale: Vector2
var doubled_scale: Vector2

var scaling = false
var scale_timer = 0.0
var scale_duration = 0.5  # Time in seconds for the scale transition
var target_scale = Vector2(0.7, 0.7)  # Adjust to how large you want it to grow
var qtePressedCount = 0

@onready var glassShatter = get_node("/root/Main/GlassShatter")
@onready var background = get_node("/root/Main/scrollingBackground")

var queued_anim: String = ""
var ignoreMouseScale = false

var burn = false # Enemy receives damage over time.
@onready var burnTimer = $BurnTimer
@onready var burnTickTimer = $BurnTickTimer

var dampen = false # Enemy damage received is echoed. 
@onready var dampenTimer = $DampenTimer

var dizzy = false # Enemy is easier to land crits on, and they do more crit damage.
var dizzyCritRateBoost = 30
var dizzyCritDamageBoost = 1
@onready var dizzyTimer = $DizzyTimer

var petrify = false # Enemy takes massive damage upon status' end, based on how much damage enemy accumulated while status was active
var petrifyDamage = 0
@onready var petrifyTimer = $PetrifyTimer

var paralysis = false # Player recovers extra ult points upon hit
@onready var paralysisTimer = $ParalysisTimer

@onready var statusIconList = [$"StatusHolder/Status 1", $"StatusHolder/Status 2", $"StatusHolder/Status 3", $"StatusHolder/Status 4", $"StatusHolder/Status 5"]
var appliedStatus = []

@onready var burnNumberPosition = $BurnNumberPosition
@onready var dampenNumberPosition = $DampenNumberPosition

@onready var tooltip = get_node("/root/Main/Tooltip")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")

var statusFrames = {
	"Burn": 0,
	"Dampen": 1,
	"Dizzy": 2,
	"Paralysis": 3,
	"Petrify": 4
}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	setInvisible()
	anim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	health = baseHealth * (1 + 0.2 * (player.level - 1))
	maxHealth = health
	healthBar.max_value = health
	healthBar.init_health(health)
	
	# Determine if a monster has a break meter or not. Early game monsters shouldn't, as the player should just get used to clicking
	# with no other distractions for a while, and THEN we implement enemy gimmicks. 
	
	if(player.level >= breakPrereqLevel):
		breakable = randi() % 2 == 1  # True or False randomly
		#breakable = false # Debug for when never breakable is desired
		if(breakable):
			breakable = true #This enemy WILL have a break meter. Set it up
			breakBar.visible = true
			breakAmount = baseBreak * (1 + 0.2 * (player.level - 1))
			healthBar.init_break(breakAmount)
	
	
	player.currentEnemy = self
	
	# Scalar
	scalarLevel = (1 + 0.2 * (player.level - 1))
	expToGive *= scalarLevel
	defeatPoints *= scalarLevel
	moneyToGive *= scalarLevel
	
	enemyPassive = enemyName

	qteSpawnTimer.connect("timeout", Callable(self, "_on_qte_spawn_timer_timeout"))
	original_scale = scale
	doubled_scale = original_scale * 2
	
	for icon in statusIconList:
		
		var area = icon.get_node("Area2D")
		area.connect("mouse_entered", Callable(self, "_on_mouse_entered_status").bind(icon))
		area.connect("mouse_exited", Callable(self, "_on_mouse_exited_status"))
		
		icon.visible = false
		icon.set_meta("status_name", null)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if broken:
		recoveringFromBreak(_delta)
		
	if scaling:
		scale_timer += _delta
		var t = clamp(scale_timer / scale_duration, 0.0, 1.0)
		scale = lerp(scale, target_scale, t)

		if t >= 1.0:
			scaling = false  # Stop when finished
			
	manageStatusIcons()
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	
	if(mouseInsideRadius):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On left mouse click...
			equipmentManager.performWeaponAction("left")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: #On right mouse click...
			equipmentManager.performWeaponAction("right")
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed: #On middle mouse click...
			# They can't use the ult big move....but they can enter ultRush
			if(!player.ultBarSystem.canUltRushBurst && player.ultBarSystem.canUltRush):
				player.useUltRush()
			# THEY CAN USE THE ULT BIG MOVE
			elif(player.ultBarSystem.canUltRushBurst):
				player.useUltRushBurst()
				player.ultBarSystem.endUltRush()
			else:
				# Regular ult
				player.useUlt()
					
func takeDamage(damage, breakMult):
	health -= damage
	healthBar.health = health
	
	defeatEnemyCheck()
	if(health > 0):
		var breakTotal = ceil(damage / 4) * breakMult
		
		if(breakTotal < 1): # At least, do 5 break damage
			breakTotal = 5
			
		if(!ultBarSystem.inUltRush):
			takeBreakDamage(breakTotal)
		
		manageDampen(damage)
		managePetrify(damage)
		manageParalysis()

	
func takeBreakDamage(breakDamage):
	if(breakable):
		if(!broken):
			breakAmount -= breakDamage
			healthBar.breakVal = breakAmount
			print("Break Bar Amount: ", healthBar.breakVal)
			print("Break amount: ", breakAmount)
		if(breakAmount <= 0):
			if(health >= 0):
				if(!recovering):
					broken = true
					initiateBreak()
			
func initiateBreak():
	if(!inQTEState):
		qteCurrentCounter = 0  # Reset counter
		qtePressedCount = 0
		breakState = true
		ignoreMouseScale = true
		turnOffUI()
		timerPause()
		collision.disabled = true
		inQTEState = true
		spawned_qte_positions.clear()  # Reset list before spawning new QTEs
		qteSpawnTimer.wait_time = 0.1
		player.rankNum = 0
		breakScreen.visible = true
		breakScreenAnim.play("BreakTextZoom")
		start_scaling(original_scale * 0.9, 0.8)  # Slowly shrink a little
	
func _on_qte_spawn_timer_timeout():
	qteSpawnTimer.wait_time = 1
	print(qteCurrentCounter)
	if qteCurrentCounter < qteCount - 1:
		spawnQTE(false)
		qteCurrentCounter += 1
		qteSpawnTimer.start()  # Restart the timer for the next QTE
	elif qteCurrentCounter >= qteCount - 1:
		spawnQTE(true)
		qteCurrentCounter += 1
		qteSpawnTimer.stop()
	
func endQTEState():
	inQTEState = false

# Called by "Ult manager code" so that the fist animation deals damage when it is finished playing
func shrinkAndDealDamage():
	start_scaling(original_scale, 0.5) 
	await get_tree().create_timer(0.1).timeout
	
	player.breakSlash()
	turnOnUI()
	glassShatterEffect()
	timersResume()
	breakState = false
	collision.disabled = false
				
func recoveringFromBreak(delta):
	if broken:
		if not inQTEState:
			ignoreMouseScale = false
			breakAmount = move_toward(breakAmount, 100, break_recovery_speed * delta)
			healthBar.breakVal = breakAmount
			recovering = true
			$BreakRecoveryFlash.play("recoveryFlash")
			# Switch to Shock animation but keep same frame
			var current_frame = anim.frame
			if anim.animation != "Shock":
				anim.play("Shock")
				anim.frame = current_frame

	if breakAmount >= 100:
		broken = false
		recovering = false
		$BreakRecoveryFlash.stop()
		var current_frame = anim.frame
		if anim.animation != "Idle":
			anim.play("Idle")
			anim.frame = current_frame
	
func defeatEnemyCheck():
	if(health <= 0):
		broken = false
		if(canGrantExp):
			canGrantExp = false
			player.stopDrilling("left")
			player.stopDrilling("right")
			
			#player.gainExp(expToGive)
			generateExpParticles()
			
			player.score += defeatPoints
			player.updateMoney(moneyToGive)
			monsterCapture()
			
			var defeatAnimRng = 0
			defeatAnim.play(defeatAnimationList[defeatAnimRng])
			if(ultBarSystem.inUltRush): #Skip the animation and just spawn the new enemy
				defeatAnimCleanup()
			area.visible = false
			healthBar.visible = false
		
		
func _on_area_2d_mouse_entered():
	mouseInsideRadius = true
	if(!ignoreMouseScale):
		if $EnemyScale.is_playing():
			queued_anim = "EnemyScaleUp"
		else:
			$EnemyScale.play("EnemyScaleUp")
		
func _on_area_2d_mouse_exited():
	mouseInsideRadius = false
	
	player.stopDrilling("left") #Drills tend to be able to keep drilling even when cursor isnt on the enemy, so...
	player.stopDrilling("right")
	
	if(!ignoreMouseScale):
		if $EnemyScale.is_playing():
			queued_anim = "EnemyScaleDown"
		else:
			$EnemyScale.play("EnemyScaleDown")

func _on_enemy_scale_animation_finished(anim_name):
	if queued_anim != "":
		var next_anim = queued_anim
		queued_anim = "" # Clear it so it doesn't loop forever
		$EnemyScale.play(next_anim)

func defeatAnimCleanup():
	if(!ultBarSystem.inUltRush):
		enemyManager.spawnEnemy()
		queue_free()
	if(ultBarSystem.inUltRush):
		enemyManager.spawnEnemyUltRush()
		queue_free()

	
func monsterCapture():
	var captureRng = randi_range(0, 100)
	if(captureRate >= captureRng):
		#playerCapture.captureMonster(enemyName, enemyPassive)
		playerCapture.generateCaptureParticle(enemyName, enemyPassive)

func setInvisible(): #Set the monster and their healthbar invisible at the start
	$Health_Bar.modulate.a = 0
	$Area2D.modulate.a = 0
	
# Function to set a random position within the specified limits
func spawnRushQTE():
	var random_position
	var xPos = 0
	var yPos = 0

	# Generate a random position
	var rng = randi() % 2
	if(rng == 0):
		xPos = leftLimit2
	else:
		xPos = rightLimit2
	
	rng = randi() % 2
	
	if(rng == 0):
		yPos = topLimit2
	else:
		yPos = bottomLimit2
		
	random_position = Vector2(xPos, yPos)
	
	var qte_instance = qteRush.instantiate()
	qte_instance.position = random_position
	qte_instance.rushQTE = true
	qte_instance.setup_qte() 
	
	# Find the Main node and add the QTE instance as its child
	var mainNode = get_tree().get_root().find_child("Main", true, false)
	if mainNode:
		mainNode.add_child(qte_instance)
	else:
		print("Error: Main node not found!")
		
	spawned_qte_positions.append(random_position)  # Track position
	
		
func spawnQTE(finalQteVal):
	
	var max_attempts = 3333  # Avoid infinite loops
	var attempts = 0
	var valid_position = false
	var random_position
	
	while !valid_position and attempts < max_attempts:
		# Generate a random position
		var random_x = randf_range(leftLimit, rightLimit)
		var random_y = randf_range(topLimit, bottomLimit)
		random_position = Vector2(random_x, random_y)
		
		# Check if it's too close to an existing QTE
		valid_position = true
		for pos in spawned_qte_positions:
			if pos.distance_to(random_position) < 300:  # Adjust variable to control spacing
				valid_position = false
				break
		
		attempts += 1
		
	if(attempts >= max_attempts):
		var qte_instance = qte.instantiate()
		qte_instance.position = random_position
		
		# Find the Main node and add the QTE instance as its child
		var mainNode = get_tree().get_root().find_child("Main", true, false)
		if mainNode:
			mainNode.add_child(qte_instance)
		else:
			print("Error: Main node not found!")
			
		spawned_qte_positions.append(random_position)  # Track position

	if valid_position:
		var qte_instance = qte.instantiate()
		qte_instance.position = random_position
		
		# Find the Main node and add the QTE instance as its child
		var mainNode = get_tree().get_root().find_child("Main", true, false)
		if mainNode:
			mainNode.add_child(qte_instance)
		else:
			print("Error: Main node not found!")
			
		spawned_qte_positions.append(random_position)  # Track position

func turnOffUI(): #Shut off all UI to make the break more cinematic
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		ui.visible = false
		
func turnOnUI():
	for ui in get_tree().get_nodes_in_group("BreakUIShut"):
		if(ui not in get_tree().get_nodes_in_group("DontTurnBackOn")):
			ui.visible = true
		if(ui in get_tree().get_nodes_in_group("memberData")):
			if("open" in ui):
				ui.open = false
		
# Call this function to manually scale
func start_scaling(new_scale: Vector2, duration: float):
	target_scale = new_scale
	scale_duration = duration
	scale_timer = 0.0
	scaling = true
	
func stop_scaling():
	scale_timer = 0.0
	scaling = false

func glassShatterEffect():
	glassShatter.visible = true
	glassShatter.playAnim()
	
func flashBackgroundRed():
	background.flashRed()
	
func glassShatterImpact():
	$HitShakeAnim.play("hitShake")
	$DamageFlashAnim.play("flashRed")
	flashBackgroundRed()
	
func generateExpParticles():
	# Target Spots
	var float_target_spots: Array[Vector2] = []
	var particleHolders = get_node("/root/Main/ParticleHolders")
	
	# Get all target spot locations stored in target spot variable
	for i in particleHolders.get_children():
		if(i.is_in_group("ExpSpot")):
			float_target_spots.append(i.global_position)
		
	var num_particles = 5
	for i in range(num_particles):
		var particle = preload("res://Scenes/ExperienceParticle.tscn").instantiate()
		get_tree().root.get_node("Main").add_child(particle)
		particle.global_position = self.global_position
		
		var exp_bar = get_node("/root/Main/ExpBarSystem/TextureProgressBar/LevelText")
		
		if(i < 5): #Assign 1 to each target spot (there are 5 currently)
			var rng = randi_range(-40, 40)
			var posX = float_target_spots[i].x + rng
			rng = randi_range(-40, 40)
			var posY = float_target_spots[i].y + rng
			particle.float_target_position = Vector2(posX, posY)
		
		else:
			var rng = randi_range(0, float_target_spots.size()); #If more than 5, assign it randomly
			particle.float_target_position = float_target_spots[rng]
			
		particle.target_position = exp_bar.global_position  # global position of bar
		particle.exp_bar_ref = exp_bar
		particle.exp_value = expToGive / num_particles  # divide the total EXP
		
		particle.start_float()

#Initiate burn		
func startBurn():
	if(burn):
		#Initial Burn damage
		manageBurn()
		burnTickTimer.start()
		
# Deal damage
func manageBurn():
	
	takeDamage(maxHealth / 20.0, 1)
	var rngX = randi_range(-20, 10)
	var rngY = randi_range(-10, 0)
	var damageNumPos = burnNumberPosition.global_position + Vector2(rngX, rngY)
	DamageNumber.display_burn_number(maxHealth / 20.0, damageNumPos, false) #Display damage number and attack animation upon hit

#Inflict damage on timeout
func _on_burn_tick_timer_timeout():
	if(burn):
		manageBurn()
		
func manageDampen(damage: int):
	if(dampen):
		var dampenDamage = damage / 4
		if(dampenDamage <= 0):
			dampenDamage = 1	
		health -= dampenDamage
		healthBar.health = health
		print("dampen damage being taken: ", dampenDamage)
		
		var damageNumPos = dampenNumberPosition.global_position
		DamageNumber.display_dampen_number(dampenDamage, damageNumPos, false) #Display damage number and attack animation upon hit
		
		# I believe you could add managePetrify here too if desired
		
		defeatEnemyCheck()

func managePetrify(damage: int):
	if(petrify):
		petrifyDamage += damage
		
func manageParalysis():
	if(paralysis):
		player.ultBarSystem.updateUltProgress(80)
	
# For the "Dizzy" status effect... the enemy has 2 variables called dizzyCritRateBoost and dizzyCritDamageBoost
# Dizzy is managed in the determineDamage function of the player

func _on_burn_timer_timeout():
	burn = false
	burnTickTimer.stop()
	print("Burning over")

	clear_status_icon("Burn")
			
func _on_dampen_timer_timeout():
	dampen = false
	print("No more: Dampen")
	clear_status_icon("Dampen")
	
func _on_dizzy_timer_timeout():
	dizzy = false
	print("No more: Dizzy")
	clear_status_icon("Dizzy")

func _on_petrify_timer_timeout():
	petrify = false
	takeDamage(petrifyDamage, 1)
	print("Petrify Damage = ", petrifyDamage)
	
	var damageNumPos = damageNumberPosition.global_position
	DamageNumber.display_petrify_number(petrifyDamage, damageNumPos, false) #Display damage number and attack animation upon hit
	
	petrifyDamage = 0
	print("No more: Petrify")
	clear_status_icon("Petrify")

func _on_paralysis_timer_timeout():
	paralysis = false
	print("No more: Paralysis")
	clear_status_icon("Paralysis")
	
func manageStatusIcons():
	if(!breakState): #We dont manage status icons or status effects when broken
		for icon in statusIconList:
			if icon.visible:
				var status_name = icon.get_meta("status_name")
				var timer = get_node(status_name + "Timer")
				
				if timer:
					var fill_bar = icon.get_node("StatusFill")
					fill_bar.value = 10 - timer.time_left
				
func clear_status_icon(status_name: String) -> void:
	for icon in statusIconList:
		if icon.visible and icon.get_meta("status_name") == status_name:
			icon.visible = false
			icon.get_node("StatusFill").value = 0
			icon.set_meta("status_name", null)
			appliedStatus.erase(status_name)
			break

		
func applyStatusIcon(status_name: String) -> void:
	if appliedStatus.has(status_name):
		return # Already applied

	# Find the next available icon slot
	for icon in statusIconList:
		if icon.visible == false:
			icon.visible = true
			icon.frame = statusFrames[status_name]
			icon.set_meta("status_name", status_name)
			appliedStatus.append(status_name)
			break
			
func _on_mouse_entered_status(icon: Node):
	var status_name = icon.get_meta("status_name")
	var tooltip_text = ""
	
	match status_name:
		"Burn":
			tooltip_text = "Burn"
		"Dampen":
			tooltip_text = "Dampen"
		"Dizzy":
			tooltip_text = "Dizzy"
		"Paralysis":
			tooltip_text = "Paralysis"
		"Petrify":
			tooltip_text = "Petrify"
			
	tooltip.show_tooltip(tooltip_text)
	
func _on_mouse_exited_status():
	tooltip.hide_tooltip()
		
var activeTimers = {}
	
func timerPause():
	activeTimers.clear()
	
	for timer in [burnTimer, burnTickTimer, dampenTimer, dizzyTimer, petrifyTimer, paralysisTimer]:
		if not timer.is_stopped():
			activeTimers[timer] = true
			timer.paused = true
			
	# Only hide icons that actually have a status applied
	for icon in statusIconList:
		if icon.has_meta("status_name") and icon.get_meta("status_name") != null:
			icon.visible = false

func timersResume():
	for timer in activeTimers.keys():
		timer.paused = false
	
	# Only re‑show icons that still have a status applied
	for icon in statusIconList:
		if icon.has_meta("status_name") and icon.get_meta("status_name") != null:
			icon.visible = true
	
