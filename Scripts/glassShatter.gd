extends Node2D

@onready var anim = $AnimationPlayer
@onready var player = get_node("/root/Main/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func playAnim():
	anim.play("glassShatter")
	
# Functions on the current enemy within the player node that add impact to the glass shatter animation
func enemyImpactEffects():
	if(player != null):
		if(player.currentEnemy != null):
			player.currentEnemy.glassShatterImpact()
