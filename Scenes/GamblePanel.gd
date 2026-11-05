extends Control
@onready var gridContainer = $GridContainer
@onready var player = get_node("/root/Main/Player")
@onready var shopUI = get_node("/root/Main/ShopUI")
@export var useGambleTimer: bool = true
@export var gambleCost: int = 10000
@export var gambleCooldownDuration: float = 2.0
var gambleOnCooldown: bool = false
var gambleCooldownRemaining: float = 0.0
var isGambling: bool = false
var gambleSlots: Array = []
@onready var gambleBlipSE = $GambleBlip
@onready var gambleSelectSE = $GambleSelect

func _ready():
	for child in get_tree().get_nodes_in_group("IndividualGambleSlot"):
		if child.get_parent() == gridContainer:
			gambleSlots.append(child)
	call_deferred("updateGambleCostLabel")

func _process(delta):
	if gambleOnCooldown:
		gambleCooldownRemaining -= delta
		if gambleCooldownRemaining <= 0.0:
			gambleOnCooldown = false
			gambleCooldownRemaining = 0.0
			updateGambleCostLabel()
			shopUI.gambleButton.disabled = false
		else:
			updateGambleTimerLabel()

func spinAndSelectSlot() -> Control:
	var total_weight = 0
	for slot in gambleSlots:
		total_weight += slot.weight
	var roll = randi_range(1, total_weight)
	var cumulative = 0
	for slot in gambleSlots:
		cumulative += slot.weight
		if roll <= cumulative:
			return slot
	return gambleSlots[-1]

func attemptGamble():
	if isGambling or gambleOnCooldown:
		return
	if player.score < gambleCost:
		shopUI.playNotEnoughMoneySE()
		return
	isGambling = true
	shopUI.gambleButton.disabled = true
	player.transactionScoreUpdate(gambleCost * -1)
	
	# Start spinning
	await spin_slots()
	
	isGambling = false
	if useGambleTimer:
		gambleOnCooldown = true
		gambleCooldownRemaining = gambleCooldownDuration
		updateGambleTimerLabel()
	else:
		shopUI.gambleButton.disabled = false

func spin_slots():
	var winning_slot = spinAndSelectSlot()
	var spin_speed = 0.1
	var min_spin_speed = 0.4
	var spin_duration = 0.0
	var max_spin_duration = randf_range(3.5, 4.5)
	var last_slot = null
	
	for slot in gambleSlots:
		slot.resetGlow()
	
	while spin_duration < max_spin_duration:
		var random_slot = gambleSlots[randi() % gambleSlots.size()]
		
		while random_slot == last_slot:
			random_slot = gambleSlots[randi() % gambleSlots.size()]
		
		last_slot = random_slot
		
		for slot in gambleSlots:
			slot.resetGlow()
		random_slot.glow()
		gambleBlip()  # <-- plays on every switch during the spin
		
		spin_speed = lerp(0.1, min_spin_speed, spin_duration / max_spin_duration)
		await get_tree().create_timer(spin_speed).timeout
		spin_duration += spin_speed
	
	for slot in gambleSlots:
		slot.resetGlow()
	
	winning_slot.glow()
	await get_tree().create_timer(1.0).timeout
	
	gambleSelectSE.play()  # <-- plays once, when the winner is finally locked in
	
	for i in range(6):
		winning_slot.glow()
		await get_tree().create_timer(0.15).timeout
		
		for slot in gambleSlots:
			slot.resetGlow()
		await get_tree().create_timer(0.15).timeout
	
	# Keep final glow on winner
	winning_slot.glow()
	
	winning_slot.apply_reward()
	
	# Check if mouse is still on gamble button, if not fade out
	var mouse_pos = get_global_mouse_position()
	var gamble_button_rect = shopUI.gambleButton.get_global_rect()
	
	if not gamble_button_rect.has_point(mouse_pos):
		# Fade out the panel
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(func(): visible = false)
		
func updateGambleCostLabel():
	if not shopUI or not shopUI.gambleButton:
		return
	var costLabel = shopUI.gambleButton.get_node_or_null("Cost")
	if costLabel:
		costLabel.text = str(gambleCost)

func updateGambleTimerLabel():
	if not shopUI or not shopUI.gambleButton:
		return
	var costLabel = shopUI.gambleButton.get_node_or_null("Cost")
	if costLabel:
		var total_seconds = int(ceil(gambleCooldownRemaining))
		var minutes = total_seconds / 60
		var seconds = total_seconds % 60
		costLabel.text = "%01d:%02d" % [minutes, seconds]
		
func gambleBlip():
	var rng = randf_range(0.8, 1.2)
	gambleBlipSE.pitch_scale = rng
	gambleBlipSE.play()

