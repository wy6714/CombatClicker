extends Node2D

var rng #Determines what type of explosion
@onready var anim = $AnimationPlayer #The explosion trigger
@onready var se1 = $RushExplosionSE1
@onready var se2 = $RushExplosionSE2

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = randi() % 2 # 0 or 1
	if(rng == 0):
		anim.play("Explosion1")
	if(rng == 1):
		anim.play("Explosion2")
		
	#Just play the sound effect at the start, node is gonna immediately blow up anyhow. Or maybe not. Idk.
	#playAlteredAudio()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func playAlteredAudio():
	var rngAudio = randf_range(0.8, 1.2)
	if(rng == 0):
		se1.pitch_scale = rngAudio
		se1.play()
	if(rng == 1):
		se2.pitch_scale = rngAudio
		se2.play()
