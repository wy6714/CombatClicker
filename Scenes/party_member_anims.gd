extends Node2D

@onready var memberNumber = $MemberNumber
@onready var anim = $AnimationPlayer
@onready var particles = $CPUParticles2D

@export var fireColor: Color = Color(0,0,0)
@export var waterColor: Color = Color(0,0,0)
@export var windColor: Color = Color(0,0,0)
@export var earthColor: Color = Color(0,0,0)
@export var electricColor: Color = Color(0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func playPunch():
	anim.play("punch")

func playKick():
	anim.play("kick")
	print("playing kick")
	
func setMemberInfo(number, element):
	memberNumber.text = number

	match element:
		"Fire":
			particles.modulate = fireColor
			memberNumber.modulate = fireColor
		"Water":
			particles.modulate = waterColor
			memberNumber.modulate = waterColor
		"Wind":
			particles.modulate = windColor
			memberNumber.modulate = windColor
		"Earth":
			particles.modulate = earthColor
			memberNumber.modulate = earthColor
		"Electric":
			particles.modulate = electricColor
			memberNumber.modulate = electricColor

	
