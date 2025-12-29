extends Node2D

var animations = ["SwordAnim", "SwordAnim2", "SwordAnim3"]
var claymoreAnimations = ["Claymore1", "Claymore2", "Claymore3"]
@onready var slashSE = $SwordSE
@onready var claymoreSlashSE = $ClaymoreSE
@onready var claymoreFlimsySlashSE = $FlimsyClaymoreSE
@onready var player = get_node("/root/Main/Player") # Get a reference to the player

@onready var normalSE = preload("res://Audio/SlashSE.wav")
@onready var slimySE = preload("res://Audio/Sound Effect Good!.mp3")
@onready var whispySE = preload("res://Audio/UpgradeSound.mp3")
@onready var solidSE = preload("res://Audio/RushExplosion1.wav")


func _on_animation_player_animation_finished(anim_name):
	if anim_name in animations:
		queue_free()  # Queue free if any of the sword animations finishes
		
func determineAnimation(animCombo):
	$AnimationPlayer.play(animations[animCombo])  # Play the animation corresponding to the combo index
	# This combo index allows for a series of animations, a right slash, a left slash, and then a downward slash. 
	#Simply allows for a satisfying animation combo
	
func determineAnimationClaymore(animCombo):
	$AnimationPlayer.play(claymoreAnimations[animCombo])  # Play the animation corresponding to the combo index
	# This combo index allows for a series of animations, a right slash, a horizontal slash, and then a downward slash. 
	#Simply allows for a satisfying animation combo

func drillAnimation():
	$AnimationPlayer.play("Drill")
		
func ultAnimation():
	$AnimationPlayer.play("UltExplosion")
	
func flimsyClaymoreAnimation():
	$AnimationPlayer.play("ClaymoreFlimsy")
	
func ultDamage():
	player.ultDamage()
	
func playAlteredAudio():
	var rng = randf_range(0.4, 1.2) # Pitch variance
	slashSE.pitch_scale = rng # Apply pitch variance
	
	# Map enemy types to streams
	var sfx_map = {
		player.currentEnemy.EnemyType.NORMAL: normalSE,
		player.currentEnemy.EnemyType.SLIMY: slimySE,
		player.currentEnemy.EnemyType.WHISPY: whispySE,
		player.currentEnemy.EnemyType.SOLID: solidSE
	}
	
	var stream = sfx_map.get(player.currentEnemy.enemy_type, normalSE)
	if(stream == null):
		print("uh oh")
		return
	
	slashSE.stream = stream
	slashSE.play()
	
func playAlteredAudioClaymore():
	var rng = randf_range(0.4, 1.2)
	claymoreSlashSE.pitch_scale = rng
	claymoreSlashSE.play()

func playAlteredAudioClaymoreFlimsy():
	var rng = randf_range(0.4, 1.2)
	claymoreFlimsySlashSE.pitch_scale = rng
	claymoreFlimsySlashSE.play()
	
func stopAnimation():
	$AnimationPlayer.play("RESET")
	
func alterUltExplosionSE1():
	var rng = randf_range(0.9, 1.1)
	$UltExplosion1.pitch_scale = rng
	$UltExplosion1.play()
	
func alterUltExplosionSE2():
	var rng = randf_range(0.9, 1.1)
	$UltExplosion2.pitch_scale = rng
	$UltExplosion2.play()
	

