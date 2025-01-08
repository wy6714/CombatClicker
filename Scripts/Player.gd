extends Node2D

@export var strength: int = 1
@export var critRate: float = 5
@export var critDamage: int = 2
@export var crit: bool = false # Tracking IF we crit
@export var damage: int = 0
@export var score: int = 0 #Our current score (also currency)
@export var maxScore: int = 0 # Our TOTAL score accumulated throughout the entirety of playtime. (NOT currency)
@export var totalClicks: int = 0 # Our total clicks we have done ever. Seems good to track this

@export var level: int = 1
@export var currentExp: int = 0
@export var expToNextLevel: int = 100
@onready var expBarSystem = get_node("/root/Main/ExpBarSystem") # Get a reference to the levelSystem


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func determineDamage():
	damage = strength
	var rng = randf_range(1, 100)
	if(rng <= critRate):
		crit = true
		damage = damage * critDamage

func gainExp(exp):
	currentExp += exp;
	levelUp()
	expBarSystem.expBar.value = currentExp

func levelUp():
	if(currentExp >= expToNextLevel):
		print("levelled up!")
		level += 1
		expBarSystem.levelText.text = "Lv: " + str(level)
		var expOverflow = currentExp - expToNextLevel
		currentExp = 0
		currentExp += expOverflow
		print("POST LEVEL EXP: ", currentExp)
		
		#Update strength text upon level...?
		#strength += 1
		#var strengthText = get_node("/root/Main/Scoreboard/StrengthNum")
		#strengthText.text = str(strength) 
		#critRate += 1
		#crit rate text upgdate
		#var critText = get_node("/root/Main/Scoreboard/critRateNum")
		#critText.text = str(critRate)
