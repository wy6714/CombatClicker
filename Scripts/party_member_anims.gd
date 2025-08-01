extends Node2D

@onready var memberNumber = $MemberNumber
@onready var anim = $AnimationPlayer
@onready var particles = $CPUParticles2D

@export var fireColor: Color = Color(0,0,0)
@export var waterColor: Color = Color(0,0,0)
@export var windColor: Color = Color(0,0,0)
@export var earthColor: Color = Color(0,0,0)
@export var electricColor: Color = Color(0,0,0)

@onready var partyMemberSoundEffect1 = preload("res://Audio/PartyMemberSE1.wav")
@onready var partyMemberSoundEffect2 = preload("res://Audio/PartyMemberSE2.wav")
@onready var partyMemberSoundEffect3 = preload("res://Audio/PartyMemberSE3.wav")
@onready var partyMemberSoundEffect4 = preload("res://Audio/PartyMemberSE4.wav")

@onready var audio = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func playPunch():
	anim.play("punch")
	playRandomPartyMemberAudio()

func playKick():
	anim.play("kick")
	playRandomPartyMemberAudio()
	
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

# Play audio... if... it isnt too annoying
func playRandomPartyMemberAudio():
	
	var sounds = [partyMemberSoundEffect1, partyMemberSoundEffect2, partyMemberSoundEffect3, partyMemberSoundEffect4]
	audio.pitch_scale = randf_range(0.8, 1.2)
	audio.stream = sounds.pick_random()
	audio.play()
