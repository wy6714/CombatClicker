extends Control


@onready var player = get_node("/root/Main/Player")
@onready var breakEffect = $"."
@onready var explosions = $Explosions

var scaleTime = 0.0
var scaleTimeLimit = 2.0  # The time it takes to shrink
var startScale = 9.0  # Initial scale of the circle
var endScale = 1.9  # Final scale of the circle
var shrinking = false  # Control variable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "BreakTextZoom"):
		player.currentEnemy.qteSpawnTimer.start()
		breakEffect.visible = false
		
func enemySpriteGrowth():
	player.currentEnemy.start_scaling(player.currentEnemy.original_scale * 2.4, 3)
	
	# Wait until scaling is done, then trigger shrink
	await get_tree().create_timer(0.7).timeout
	enemySpriteShrink()
	
func enemySpriteShrink():
	player.currentEnemy.start_scaling(player.currentEnemy.original_scale * 2, 788)

func playDrumRoll():
	$DrumRoll.play()
	
func playShatterCrunch():
	$ShatterCrunch.play()
	
func playDrumCrash():
	$DrumCrash.play()
	
func playExplosion1():
	breakEffect.visible = true
	$ExplosionAnim.play("Explosion")
	$AnimationPlayer.play("BreakFinale")
	
func playExplosion2():
	$ExplosionAnim.play("Explosion2")
	
func triggerFinalQTEEffects():
	finalQTEEffects()
	
func finalQTEEffects():
	print("aha hi...!")
	player.currentEnemy.endQTEState()
	player.currentEnemy.shrinkAndDealDamage()
