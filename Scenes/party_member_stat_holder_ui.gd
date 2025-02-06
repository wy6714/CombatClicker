extends Control

@onready var strengthVal = $StrengthPoints
@onready var critRateVal = $CritRatePoints
@onready var critDamageVal = $CritDamagePoints
@onready var ultRegenVal = $UltRegenPoints
@onready var cooldownVal = $CooldownPoints

@onready var upgradePointText = $UpgradePoints
@onready var upgradePointCostText = $BuyUpgrade/UpgradePointsCost
@export var upgradePoints: int = 0
@export var upgradePointCost: int = 1000
@export var upgradeCostMultiplier: float = 1.0

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
	
func _on_buy_upgrade_button_down():
	upgradePoints += 1
	upgradePointText.text = "Upgrade Points " + str(upgradePoints)
	upgradeCostMultiplier += 0.1
	upgradePointCost *= upgradeCostMultiplier
	upgradePointCostText.text = str(upgradePointCost) + " points"
