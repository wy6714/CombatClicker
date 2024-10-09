extends Node2D

var animations = ["SwordAnim", "SwordAnim2", "SwordAnim3"]
@onready var slashSE = $AudioStreamPlayer2D

func _on_animation_player_animation_finished(anim_name):
	if anim_name in animations:
		queue_free()  # Queue free if any of the sword animations finishes
		
func determineAnimation(animCombo):
	$AnimationPlayer.play(animations[animCombo])  # Play the animation corresponding to the combo index
	# This combo index allows for a series of animations, a right slash, a left slash, and then a downward slash. 
	#Simply allows for a satisfying animation combo
	print(animCombo)
	
func playAlteredAudio():
	var rng = randf_range(0.4, 1.2)
	slashSE.pitch_scale = rng
	slashSE.play()

