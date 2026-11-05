
extends Node2D

var animations = [
	"SwordAnim",
	"SwordAnim2",
	"SwordAnim3",
	"Claymore1",
	"Claymore2",
	"Claymore3",
	"ClaymoreFlimsy"
]

var claymoreAnimations = [
	"Claymore1",
	"Claymore2",
	"Claymore3"
]

# Track what type of attack this is.
var attack_type: String = "normal"  # "normal", "crit", "charged", "charged_crit"

@onready var slashSE = $SwordSE
@onready var claymoreSlashSE = $ClaymoreSE
@onready var claymoreFlimsySlashSE = $FlimsyClaymoreSE

@onready var player = get_node("/root/Main/Player")

@onready var normalSE = preload("res://Audio/SlashSE.wav")
@onready var normalCritSE = preload("res://Audio/SlashCrit.wav")
@onready var normalChargedSE = preload("res://Audio/ClaymoreSlash.wav")
@onready var normalChargedCritSE = preload("res://Audio/SlashChargedCrit.wav")

@onready var slimySE = preload("res://Audio/slimy.wav")
@onready var slimyCritSE = preload("res://Audio/slimyCrit.wav")
@onready var slimyChargedSE = preload("res://Audio/slimyClaymore.wav")
@onready var slimyChargedCritSE = preload("res://Audio/slimyClaymoreCrit.wav")

@onready var whispySE = preload("res://Audio/whispy.wav")
@onready var whispyCritSE = preload("res://Audio/whispyCrit.wav")
@onready var whispyChargedSE = preload("res://Audio/whispyCharged.wav")
@onready var whispyChargedCritSE = preload("res://Audio/whispyChargedCrit.wav")

@onready var solidSE = preload("res://Audio/RushExplosion1.wav")


func _on_animation_player_animation_finished(anim_name):
	if anim_name in animations:
		queue_free()


func determineAnimation(animCombo):
	$AnimationPlayer.play(animations[animCombo])


func determineAnimationClaymore(animCombo):
	$AnimationPlayer.play(claymoreAnimations[animCombo])


func drillAnimation():
	attack_type = "normal"
	$AnimationPlayer.play("Drill")


func ultAnimation():
	attack_type = "normal"
	$AnimationPlayer.play("UltExplosion")


func flimsyClaymoreAnimation():
	attack_type = "charged"
	$AnimationPlayer.play("ClaymoreFlimsy")


func set_charged_attack(is_crit: bool):
	"""Set this as a fully charged attack."""
	attack_type = "charged_crit" if is_crit else "charged"


func ultDamage():
	player.ultDamage()


func playAlteredAudio():
	# Store the current enemy reference.
	var enemy = player.currentEnemy

	# Check that an enemy exists before accessing its properties.
	if enemy == null or not is_instance_valid(enemy):
		slashSE.stream = normalSE
		slashSE.play()
		return

	var rng = randf_range(0.7, 1.2)
	slashSE.pitch_scale = rng

	# Map enemy types to audio tracks based on attack type.
	# Use the local enemy reference throughout this function.
	var sfx_map = {
		"normal": {
			enemy.EnemyType.NORMAL: normalSE,
			enemy.EnemyType.SLIMY: slimySE,
			enemy.EnemyType.WHISPY: whispySE,
			enemy.EnemyType.SOLID: solidSE
		},
		"crit": {
			enemy.EnemyType.NORMAL: normalCritSE,
			enemy.EnemyType.SLIMY: slimyCritSE,
			enemy.EnemyType.WHISPY: whispyCritSE,
			enemy.EnemyType.SOLID: solidSE
		},
		"charged": {
			enemy.EnemyType.NORMAL: normalChargedSE,
			enemy.EnemyType.SLIMY: slimyChargedSE,
			enemy.EnemyType.WHISPY: whispyChargedSE,
			enemy.EnemyType.SOLID: solidSE
		},
		"charged_crit": {
			enemy.EnemyType.NORMAL: normalChargedCritSE,
			enemy.EnemyType.SLIMY: slimyChargedCritSE,
			enemy.EnemyType.WHISPY: whispyChargedCritSE,
			enemy.EnemyType.SOLID: solidSE
		}
	}

	# Select sounds for the current attack type.
	var attack_sounds = sfx_map.get(attack_type, sfx_map["normal"])

	# Select the sound that matches the enemy.
	var stream = attack_sounds.get(enemy.enemy_type, normalSE)

	if stream == null:
		print("uh oh")
		return

	slashSE.stream = stream
	slashSE.play()


func playAlteredAudioClaymore():
	# Store and validate the current enemy reference first.
	var enemy = player.currentEnemy

	if enemy == null or not is_instance_valid(enemy):
		if attack_type == "charged_crit":
			claymoreSlashSE.stream = normalChargedCritSE
		else:
			claymoreSlashSE.stream = normalChargedSE

		claymoreSlashSE.play()
		return

	var rng = randf_range(0.7, 1.2)
	claymoreSlashSE.pitch_scale = rng

	print("CLAYMORE: attack_type = ", attack_type)

	# Determine if this is a critical charged attack.
	var sound_type = "charged_crit" if attack_type == "charged_crit" else "charged"

	print("CLAYMORE: sound_type = ", sound_type)

	# Map enemy types for charged attacks.
	var sfx_map = {
		"charged": {
			enemy.EnemyType.NORMAL: normalChargedSE,
			enemy.EnemyType.SLIMY: slimyChargedSE,
			enemy.EnemyType.WHISPY: whispyChargedSE,
			enemy.EnemyType.SOLID: solidSE
		},
		"charged_crit": {
			enemy.EnemyType.NORMAL: normalChargedCritSE,
			enemy.EnemyType.SLIMY: slimyChargedCritSE,
			enemy.EnemyType.WHISPY: whispyChargedCritSE,
			enemy.EnemyType.SOLID: solidSE
		}
	}

	# Select sounds for the charged attack type.
	var attack_sounds = sfx_map.get(sound_type, sfx_map["charged"])

	# Select the sound that matches the enemy.
	var stream = attack_sounds.get(enemy.enemy_type, normalChargedSE)

	if stream == null:
		print("uh oh")
		return

	print("CLAYMORE: selected stream = ", stream.resource_path)

	claymoreSlashSE.stream = stream
	claymoreSlashSE.play()


func playAlteredAudioClaymoreFlimsy():
	var rng = randf_range(0.7, 1.2)
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
