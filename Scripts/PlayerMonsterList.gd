extends Node2D

# Captured monsters storage
# Format:
# {
#   "Chickadee": {
#       "count": 2,
#       "effect": "Chickadee"
#   }
# }
var capturedMonsters: Dictionary = {}

@onready var player = get_node("/root/Main/Player")
@onready var currentMonsterButton = get_node("/root/Main/CurrentMonsterIconButton")
@onready var MonsterButton = get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/MONSTERS")
@onready var shopUI = get_node("/root/Main/ShopUI")
@onready var newCaptureAudio = get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/MONSTERS/NewCaptureAudio")
@onready var targetPosition = get_node("/root/Main/CurrentMonsterIconButton/Target")
@onready var captureParticleSpawnSE = $CaptureParticleSpawnSE
@onready var playerCapturePanel = $Control
@onready var captureList = $Control/CaptureInfoPanelItems/ScrollContainer/GridContainer
@onready var radiantToggle = $Control/CaptureInfoPanelItems/RadiantToggle

signal monster_captured(monster_name: String)

func _process(delta):
	pass

func captureMonster(monsterName: String, passiveEffect: String, radiant: bool):
	if monsterName in capturedMonsters:
		capturedMonsters[monsterName]["count"] += 1
	else:
		capturedMonsters[monsterName] = {
			"count": 1,
			"effect": passiveEffect
		}
	
	if radiant:
		capturedMonsters[monsterName]["radiantUnlocked"] = true
	else:
		capturedMonsters[monsterName]["regularUnlocked"] = true
		
	print("Captured: ", monsterName, " | Total: ", capturedMonsters[monsterName]["count"])
	shopUI.newCaptureBounce()
	newCaptureAudio.play()
	
	monster_captured.emit(monsterName)

# -------------------------------------------------------------------------
# UI OPEN / CLOSE
# -------------------------------------------------------------------------

func _on_texture_button_button_up():
	$PanelFade.play("fadeOut")
	$UISlide.play("slideOut")
	randomizePitch($CaptureMenuClose)
	
	for node in get_tree().get_nodes_in_group("Player"):
		if "hoverBlocked" in node:
			node.hoverBlocked = false
	
	for node in get_tree().get_nodes_in_group("PartyMember"):
		if "hoverBlocked" in node:
			node.hoverBlocked = false

func uiSlideIn():
	$PanelFade.play("fade")
	$UISlide.play("slide")
	randomizePitch($CaptureMenuOpen)
	
	for node in get_tree().get_nodes_in_group("Player"):
		if "hoverBlocked" in node:
			node.hoverBlocked = true
	
	for node in get_tree().get_nodes_in_group("PartyMember"):
		if "hoverBlocked" in node:
			node.hoverBlocked = true

func randomizePitch(audio):
	var rng = randf_range(0.9, 1.1)
	audio.pitch_scale = rng
	audio.play()

# -------------------------------------------------------------------------
# CAPTURE EFFECT
# -------------------------------------------------------------------------

func generateCaptureParticle(enemyName: String, enemyPassive: String, shiny: bool):
	var particleHolders = get_node("/root/Main/ParticleHolders")
	var targetSpot: Vector2 = Vector2(0, 0)
	
	for i in particleHolders.get_children():
		if i.is_in_group("CaptureSpot"):
			targetSpot = i.global_position
	
	var particle = preload("res://Scenes/CaptureParticle.tscn").instantiate()
	particle.global_position = player.currentEnemy.global_position
	get_tree().root.get_node("Main").add_child(particle)
	
	particle.float_target_position = targetSpot
	particle.target_position = targetPosition.global_position
	particle.captureBarRef = currentMonsterButton
	
	particle.enemyName = enemyName
	particle.enemyPassive = enemyPassive
	particle.radiant = shiny
	
	particle.start_float()
	captureParticleSpawnSE.play()


func _on_radiant_toggle_button_down():
	# Switch the display to be the shiny one not the normal one, 
	# make the icon in the playerMonsterList gridButton be the shiny single sprite too. 
	print("hi!!!! nice shiny :>")
