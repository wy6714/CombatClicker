extends Control

@onready var strengthVal = $StrengthPoints
@onready var critRateVal = $CritRatePoints
@onready var critDamageVal = $CritDamagePoints
@onready var ultRegenVal = $UltRegenPoints
@onready var cooldownVal = $CooldownPoints

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateAllValues(strength, critRate, critDamage, ultRegen, cooldown):
	strengthVal.text = str(strength)
	critRateVal.text = str(critRate)
	critDamageVal.text = str(critDamage)
	ultRegenVal.text = str(ultRegen)
	cooldownVal.text = str(cooldown)
		
