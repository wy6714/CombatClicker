extends Node2D

@onready var anim = $AnimationPlayer
@onready var player = get_node("/root/Main/Player")

func playAnim():
	anim.play("glassShatter")
	
# Functions on the current enemy within the player node that add impact to the glass shatter animation
func enemyImpactEffects():
	if(player != null):
		if(player.currentEnemy != null):
			player.currentEnemy.glassShatterImpact()
