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
@onready var dropshadowAnim = $Area2D/DropShadow
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
var canTakeDamage = true
var currentAnimName

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
@onready var defeatAnimationList = ["defeatAnim", "spin", "knock", "anvil", "italian"]
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
@onready var timeTracker = get_node("/root/Main/scrollingBackground")

@onready var defeatSE = $DefeatSE

var currentQTE
var activeQTEList
var currentQTEBurstCount = 0

@onready var qteLocTL = $"QTERushSpawnPositions/Location Top Left"
@onready var qteLocTR = $"QTERushSpawnPositions/Location Top Right"
@onready var qteLocBR = $"QTERushSpawnPositions/Location Bottom Right"
@onready var qteLocBL = $"QTERushSpawnPositions/Location Bottom Left"
@onready var rushExplosion = preload("res://Scenes/explosion.tscn")

# TYPES OF ENEMIES SO SOUND EFFECTS CAN PLAY
enum EnemyType { NORMAL, SLIMY, WHISPY, SOLID }
@export_enum ("Normal", "Slimy", "Whispy", "Solid")
var enemy_type: int = EnemyType.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready():
	
	setInvisible()
	anim.play()
	dropshadowAnim.play()
	position = get_viewport().get_size() / 2  # Set position to the center
	health = baseHealth * (1 + 0.2 * (player.level - 1))
	maxHealth = health
	healthBar.max_value = health
	healthBar.init_health(health)
	
	# Determine if a monster has a break meter or not. Early game monsters shouldn't, as the player should just get used to clicking
	# with no other distractions for a while, and THEN we implement enemy gimmicks. 
	
	if(player.level >= breakPrereqLevel):
		breakable = randi() % 2 == 1  # True or False randomly
		breakable = false # Debug for when never breakable is desired
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
	update_shadow()
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	
	if(mouseInsideRadius):
		if(player.autoAttack == false): # DONT ACCEPT PLAYER CLICKS IF THEY ARE IN AUTO ATTACK (unless ult):
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
				pass
				#player.useUltRushBurst()
				player.ultBarSystem.endUltRush()
			else:
				# Regular ult
				player.useUlt()
					
func takeDamage(damage, breakMult):
	if(canTakeDamage):
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
	if(canTakeDamage):
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
		area.input_pickable = false
		$Area2D/CollisionShape2D.disabled = true
		
		if(ultBarSystem.inUltRush):
			ultBarSystem.increaseRushTimerDefeat()
		
		if(canGrantExp):
			canGrantExp = false
			player.stopDrilling("left")
			player.stopDrilling("right")
			
			#player.gainExp(expToGive)
			generateExpParticles(false)
			
			player.score += defeatPoints
			player.updateMoney(moneyToGive)
			monsterCapture()
			
			#SHRINK ANIM, THAT THEN CALLS DECIDE DEATH ANIM
			if(!ultBarSystem.inUltRush):
				defeatAnim.play("shrink")
			else:
				
				var explosion_instance = rushExplosion.instantiate()
				explosion_instance.global_position = global_position
				get_tree().current_scene.add_child(explosion_instance)
				defeatAnimCleanupRush() #Skip the animation and just spawn the new enemy, and EXPLOOODE
				
			
		await get_tree().create_timer(0.05).timeout	
		player.currentEnemy = null
		for member in get_tree().get_nodes_in_group("UIMember"):
			member.currentEnemy = null
	
			
func decideDeathAnim():
	var defeatAnimRng = randi_range(0, len(defeatAnimationList) - 1)
	
	defeatAnim.play(defeatAnimationList[defeatAnimRng])
	
	if(ultBarSystem.inUltRush): #Skip the animation and just spawn the new enemy
		defeatAnimCleanupRush()
		
	#area.visible = false (MAKE AREA UNCLICKABLE)
	area.input_pickable = false
	$Area2D/CollisionShape2D.disabled = true
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
		
		player.currentEnemy = null
		for member in get_tree().get_nodes_in_group("UIMember"):
			member.currentEnemy = null
		
		#Wait a bit before queue free so that animations can fully play out
		await get_tree().create_timer(2.5).timeout	
		queue_free()
	
func defeatAnimCleanupRush():
	if(ultBarSystem.inUltRush):
		enemyManager.spawnEnemyUltRush()
		await get_tree().create_timer(0.1).timeout
		player.currentEnemy = null
		for member in get_tree().get_nodes_in_group("UIMember"):
			member.currentEnemy = null
		#Wait a bit before queue free so that animations can fully play out	
		
		visible = false #explosion animation here
		
		await get_tree().create_timer(2.5).timeout
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
	
func spawnRushQTESet():
	if(ultBarSystem.inUltRush):
		var burst_count : int = 4
		var spacing : float = 130.0       # distance between spawned QTEs (no clamping)
		var per_item_delay : float = 0.35
		var min_extra : float = 0.25
		var max_extra : float = 0.50
		var max_scale_time : float = 3.0

		var mainNode = get_tree().get_root().find_child("Main", true, false)
		if not mainNode:
			print("Error: Main node not found!")
			return

		# pick one of the four anchors (use your @onready nodes)
		var anchor_index = randi() % 2
		var anchor_node: Node2D
		if anchor_index == 0:
			anchor_node = qteLocBR
		else:
			anchor_node = qteLocTR

		var base_pos : Vector2 = anchor_node.global_position

		# ---- ONLY LEFT/RIGHT variant (no up/down) ----
		var dir := Vector2.ZERO
		# TL -> RIGHT, TR -> LEFT, BR -> LEFT, BL -> RIGHT
		if anchor_index == 0:
			dir = Vector2.UP   
		elif anchor_index == 1:
			dir = Vector2.DOWN    

		# If you'd like to restore the original random choice (right OR down / left OR down / left OR up / right OR up),
		# replace the block above with the commented block below (uncomment it and comment out the left/right assignment).
		#
		# ---- COMMENTED: 50/50 direction choice (up/down allowed) ----
		# var dir := Vector2.ZERO
		# if anchor_index == 0:
		#     # TL: right or down
		#     if randf() < 0.5:
		#         dir = Vector2.RIGHT
		#     else:
		#         dir = Vector2.DOWN
		# elif anchor_index == 1:
		#     # TR: left or down
		#     if randf() < 0.5:
		#         dir = Vector2.LEFT
		#     else:
		#         dir = Vector2.DOWN
		# elif anchor_index == 2:
		#     # BR: left or up
		#     if randf() < 0.5:
		#         dir = Vector2.LEFT
		#     else:
		#         dir = Vector2.UP
		# else:
		#     # BL: right or up
		#     if randf() < 0.5:
		#         dir = Vector2.RIGHT
		#     else:
		#         dir = Vector2.UP
		# -------------------------------------------------------------

		# ensure lists exist
		if activeQTEList == null:
			activeQTEList = []
		if spawned_qte_positions == null:
			spawned_qte_positions = []

		# spawn the burst (no bounds/clamping)
		for i in range(burst_count):
			var pos = base_pos + dir * (spacing * i)

			var qte_instance = qteRush.instantiate()

			# connect immediately so we don't miss an emit
			if qte_instance.has_signal("qte_finished"):
				qte_instance.connect("qte_finished", Callable(self, "_on_qte_finished"))
			else:
				print("Warning: spawned QTE has no qte_finished signal declared")

			# set properties then add to scene (stagger appearance for i>0)
			qte_instance.position = pos
			qte_instance.rushQTE = true

			if i > 0 and per_item_delay > 0.0:
				await get_tree().create_timer(per_item_delay).timeout

			mainNode.add_child(qte_instance)

			# run setup on the instance
			if qte_instance.has_method("setup_qte_rush"):
				qte_instance.setup_qte_rush()
			else:
				print("Warning: QTE instance missing setup_qte_rush()")

			# slight slowdown for subsequent QTEs (non-cumulative)
			if i > 0:
				var extra : float = randf_range(min_extra, max_extra)
				if qte_instance.has_method("set_scale_time_limit"):
					var new_time = min(qte_instance.scaleTimeLimit + extra, max_scale_time)
					qte_instance.set_scale_time_limit(new_time)
				else:
					qte_instance.scaleTimeLimit = min(qte_instance.scaleTimeLimit + extra, max_scale_time)

			# only the first is current at spawn
			if qte_instance.has_method("set_as_current"):
				qte_instance.set_as_current(i == 0)

			# track
			spawned_qte_positions.append(pos)
			activeQTEList.append(qte_instance)

		# final housekeeping: prune freed nodes and ensure first is current
		if activeQTEList.size() > 0:
			var cleaned := []
			for q in activeQTEList:
				if is_instance_valid(q):
					cleaned.append(q)
			activeQTEList = cleaned

			for q in activeQTEList:
				if q.has_method("set_as_current"):
					q.set_as_current(false)

			if activeQTEList.size() > 0:
				currentQTE = activeQTEList[0]
				if is_instance_valid(currentQTE) and currentQTE.has_method("set_as_current"):
					currentQTE.set_as_current(true)
			else:
				currentQTE = null

		# debug:
		# print("SPAWNED FROM ANCHOR", anchor_index, "DIR", dir, "SPACING", spacing, "POSITIONS:", spawned_qte_positions)

			
func _on_qte_finished(qte_node: Node, miss: bool, good: bool, perfect: bool) -> void:
	# Defensive: if the finished node is still valid, clear its flag
	if is_instance_valid(qte_node) and qte_node.has_method("set_as_current"):
		qte_node.set_as_current(false)

	# Rebuild activeQTEList without invalid/freed nodes AND without the finished node
	var new_list := []
	for q in activeQTEList:
		# skip freed instances
		if not is_instance_valid(q):
			continue
		# skip the finished one
		if q == qte_node:
			continue
		new_list.append(q)
	activeQTEList = new_list
	
	# Advance the currentQTE to the next valid one (first in the list)
	if activeQTEList.size() > 0:
		currentQTE = activeQTEList[0]
		if is_instance_valid(currentQTE) and currentQTE.has_method("set_as_current"):
			currentQTE.set_as_current(true)
	else:
		currentQTE = null

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
	
func generateExpParticles(bonus: bool):
	# collect target spots
	var float_target_spots: Array[Vector2] = []
	var particle_holders = get_node("/root/Main/ParticleHolders")
	for child in particle_holders.get_children():
		if child.is_in_group("ExpSpot"):
			float_target_spots.append(child.global_position)

	# decide how many particles to spawn
	var num_particles: int

	if bonus:
		num_particles = 10
	else:
		num_particles = 5

	# guard: if there are no target spots, fallback to a sensible default (e.g. enemy pos)
	var spots_count := float_target_spots.size()
	if spots_count == 0:
		push_warning("generateExpParticles: no ExpSpot nodes found — using self.global_position as fallback.")
	
	for i in range(num_particles):
		var particle = preload("res://Scenes/ExperienceParticle.tscn").instantiate()
		get_node("/root/Main").add_child(particle)
		particle.global_position = self.global_position

		var exp_bar = get_node("/root/Main/ExpBarSystem/TextureProgressBar/LevelText")

		# pick a base spot (use i-th spot if available, otherwise random)
		var base_pos: Vector2
		if spots_count == 0:
			base_pos = self.global_position
		elif i < spots_count:
			base_pos = float_target_spots[i]
		else:
			# choose a random index in [0, spots_count-1]
			var idx = randi() % spots_count
			base_pos = float_target_spots[idx]

		# add a small random offset so multiple particles don't stack exactly
		var offset_x = randi_range(-40, 40)
		var offset_y = randi_range(-40, 40)
		particle.float_target_position = base_pos + Vector2(offset_x, offset_y)

		# other particle setup
		particle.target_position = exp_bar.global_position
		particle.exp_bar_ref = exp_bar
		# divide exp cleanly (optionally floor/ceil if you need integers)
		particle.exp_value = expToGive / num_particles

		# start appropriate float
		if bonus:
			particle.start_float_long()
		else:
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
	
func update_shadow():
	# --- DEBUG OVERRIDE: set to true while testing to make the whole cycle very fast ---
	var DEBUG_FAST := false
	var DEBUG_DAY_LEN := 4.0  # full loop in seconds when DEBUG_FAST is true

	# Config / safety (fast if debugging)
	var day_len = timeTracker.day_length
	if DEBUG_FAST:
		day_len = DEBUG_DAY_LEN

	if day_len <= 0.0:
		return

	# normalized time over full cycle [0..1]
	var local_time := fmod(timeTracker.time, day_len)
	var tn = local_time / day_len  # 0..1

	# Cosine pattern for base interpolation (0 -> 1 at tn=0.5 -> 0 at tn=1)
	var p := 0.5 * (1.0 - cos(PI * 2.0 * tn))

	# Key values
	var morning_pos := Vector2(127, 37)
	var evening_pos := Vector2(-103, 37)
	var morning_skew_deg := 30.0
	var evening_skew_deg := -30.0

	# Morning full scale and the tiny (shrunken) Y-scale you gave
	var morning_scale := Vector2(16, 16)
	var small_scale := Vector2(16, 4)             # keep X same, shrink Y to 4

	# The special small-phase position and a "small-phase moved-right" target
	var small_pos := Vector2(-28, 198)
	var small_pos_right := small_pos + Vector2(40, 0)  # tweak 40 to change how far it drifts right

	# Default: base interpolation between morning <-> evening (smooth)
	var base_pos := morning_pos.lerp(evening_pos, p)
	var base_skew = lerp(morning_skew_deg, evening_skew_deg, p)
	var base_scale := morning_scale   # keep normal until we enter the special small-phase

	# We'll output final_pos, final_scale, final_skew
	var final_pos := base_pos
	var final_scale := base_scale
	var final_skew = base_skew

	var local_t := -1.0 # for debug printing (only valid if tn >= 0.5)

	# --- Special small-phase after the leftmost peak (midpoint of cycle) ---
	if tn >= 0.5:
		local_t = (tn - 0.5) / 0.5  # 0..1 from mid -> end

		# Define fractions of the post-mid half-cycle for the three subphases
		var shrink_frac := 0.30   # first 30%: evening -> small_pos & shrink
		var drift_frac  := 0.40   # next 40%: small_pos -> small_pos_right (stay small)
		var expand_frac := 0.30   # final 30%: small_pos_right -> morning (expand back)

		if local_t <= shrink_frac:
			# Phase A: evening -> small_pos, shrink Y
			var s := local_t / shrink_frac   # 0..1
			final_pos = evening_pos.lerp(small_pos, s)
			final_scale = morning_scale.lerp(small_scale, s)
			final_skew = lerp(evening_skew_deg, evening_skew_deg, s)  # keep evening skew initially

		elif local_t <= (shrink_frac + drift_frac):
			# Phase B: while small, drift slightly right
			var s := (local_t - shrink_frac) / drift_frac  # 0..1
			final_pos = small_pos.lerp(small_pos_right, s)
			final_scale = small_scale
			final_skew = evening_skew_deg

		else:
			# Phase C: expand back to morning (small_pos_right -> morning_pos)
			var s := (local_t - shrink_frac - drift_frac) / expand_frac  # 0..1
			var ease_s := 0.5 * (1.0 - cos(PI * s))  # cosine ease-in-out on [0..1]
			final_pos = small_pos_right.lerp(morning_pos, ease_s)
			final_scale = small_scale.lerp(morning_scale, ease_s)
			final_skew = lerp(evening_skew_deg, morning_skew_deg, ease_s)

	# Apply results to node
	dropshadowAnim.position = final_pos
	dropshadowAnim.scale = final_scale
	_set_shadow_skew(final_skew)

func _set_shadow_skew(deg_value: float) -> void:
	# Safe detection without TYPE_* constants
	# Try to read the current property if it exists
	if not dropshadowAnim:
		return

	# Try to access dropshadowAnim.skew if it exists (use 'has' to avoid errors)
	var has_skew := false
	var current = null
	# Use `get` inside a `match` to avoid runtime errors if property isn't present
	# (some Node types won't have 'skew')
	if "skew" in dropshadowAnim:
		# property access
		# wrap in `safe` try/catch style using `match` on typeof returned value
		current = dropshadowAnim.skew
		has_skew = true

	if has_skew:
		var t = typeof(current)
		# compare against typeof(Vector2()) and typeof(0.0) to detect Vector2 vs float
		if t == typeof(Vector2()):
			dropshadowAnim.skew = Vector2(deg_to_rad(deg_value), 0.0)
			return
		elif t == typeof(0.0):
			# float (real): assume radians expected
			dropshadowAnim.skew = deg_to_rad(deg_value)
			return
		elif t == typeof(0):
			# integer -- convert
			dropshadowAnim.skew = deg_to_rad(float(deg_value))
			return

	# Fallback: try rotation_degrees if available (Node2D)
	if "rotation_degrees" in dropshadowAnim:
		dropshadowAnim.rotation_degrees = deg_value
		return

	# Final fallback: tweak scale to at least flatten
	dropshadowAnim.scale.y = 0.6
	
func animationPause(): #Pause and look stunned for rising
	var current_frame = anim.frame
	currentAnimName = anim.animation
	if anim.animation != "Shock":
		anim.play("Shock")
		anim.frame = current_frame
		
	dropshadowAnim.pause()
	anim.pause()
	canTakeDamage = false
	
func animationResume(): #Pause and look stunned for rising
	var current_frame = anim.frame
	anim.play(currentAnimName)
	anim.frame = current_frame
	anim.play()
	dropshadowAnim.play()
	canTakeDamage = true
	
func becomeShocked():
	# Switch to Shock animation but keep same frame
	var current_frame = anim.frame
	if anim.animation != "Shock":
		anim.play("Shock")
		anim.frame = current_frame		
	
func playDefeatSE():
	var rng = randf_range(0.8, 1.2)
	defeatSE.pitch_scale = rng
	defeatSE.play()
	
# Put this in your enemy script (or wherever). Call it with `await impact_shake()` if you want to wait.
func impact_shake(intensity: float = 8.0, duration: float = 0.40, frequency: int = 25) -> void:
	"""
	visual_node: Node2D to offset (recommended: a child Node2D called "Visual" with the sprite)
	intensity: max offset in PIXELS (e.g. 4..12)
	duration: total shake time in seconds
	frequency: how many micro-movements per second (higher = more frantic)
	"""

	var original_pos: Vector2 = area.position
	var steps = max(1, int(duration * frequency))
	var step_time: float = duration / float(steps)

	for i in range(steps):
		# amplitude decays toward 0 so it eases out
		var decay := 1.0 - float(i) / float(steps)
		var amp := intensity * decay

		# small random offset: X is stronger, Y is smaller
		var rx := randf_range(-amp, amp)
		var ry := randf_range(-amp * 0.35, amp * 0.35)

		var target := original_pos + Vector2(rx, ry)

		# create tween ON the visual node so it won't conflict; short ease out
		var tw = area.create_tween()
		tw.tween_property(area, "position", target, step_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tw.finished

	# snap back smoothly
	var snap_t = area.create_tween()
	snap_t.tween_property(area, "position", original_pos, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await snap_t.finished
	
func silentlyDie():
	broken = false
	area.input_pickable = false
	$Area2D/CollisionShape2D.disabled = true
	$Area2D.visible = false
	$StatusHolder.visible = false
	if(canGrantExp):
		canGrantExp = false
		generateExpParticles(true)
		player.score += defeatPoints
		player.updateMoney(moneyToGive)
		monsterCapture()
	
	await get_tree().create_timer(0.05).timeout	
	player.currentEnemy = null
	for member in get_tree().get_nodes_in_group("UIMember"):
		member.currentEnemy = null
	
	# Pause before new enemy
	await get_tree().create_timer(0.5).timeout	
	enemyManager.spawnEnemy()
	queue_free()
