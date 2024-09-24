extends Node2D

@export var strength: int = 1
@export var critRate: int = 5
@export var critDamage: int = 2
@export var crit: bool = false # Tracking IF we crit
@export var damage: int = 0
@export var score: int = 0 #Our current score (also currency)
@export var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
@export var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func determineDamage():
	damage = strength
	#Update strength text
	var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
	strengthText.text = str(strength) 
	
	var rng = randi_range(1, 100)
	if(rng <= critRate):
		crit = true
		damage = damage * critDamage

