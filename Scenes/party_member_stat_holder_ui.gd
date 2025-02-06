extends Control

@onready var strengthVal = $StrengthPoints
@onready var critRateVal = $CritRatePoints
@onready var critDamageVal = $CritDamagePoints
@onready var ultRegenVal = $UltRegenPoints
@onready var cooldownVal = $CooldownPoints

@onready var upgradePointText = $UpgradePoints
@onready var upgradePointCostText = $BuyUpgrade/UpgradePointsCost

@export var upgradePoints: int = 10
@export var upgradePointCost: int = 1000
@export var upgradeCostMultiplier: float = 1.0
@export var totalAccumulatedUpgradePoints: int = 10

@export var baseStrength: float = 10
@export var baseCritRate: float = 5 
@export var baseCritDamage: float = 2
@export var baseUltRegen: float = 1
@export var baseCooldown: float = 7

var member

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("add_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, true))

	for button in get_tree().get_nodes_in_group("remove_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, false))
		
	upgradePointText.text = "Upgrade Points " + str(upgradePoints)
	
	
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
	
func _on_upgrade_button_pressed(button, is_add):
	if is_add:
		applyUpgrade(button)
	else:
		removeUpgrade(button)

func applyUpgrade(button):
	print("Applying upgrade from:", button.name)
	
	if(upgradePoints > 0):
		if button.is_in_group("strength"):
			member.strength += 1
		if button.is_in_group("critRate"):
			member.critRate += 0.5
		if button.is_in_group("critDamage"):
			member.critDamage += 0.1
		if button.is_in_group("ultRegen"):
			member.ultRegen += 1
		if button.is_in_group("cooldown"):
			member.cooldown -= 0.2
			
		upgradePoints -= 1
		upgradePointText.text = "Upgrade Points " + str(upgradePoints)
		updateAllValues(member.strength, member.critRate, member.critDamage, member.ultRegen, member.cooldown)


func removeUpgrade(button):
	print("Removing upgrade from:", button.name)
	
	if(upgradePoints < totalAccumulatedUpgradePoints):
		if button.is_in_group("strength"):
			if member.strength > baseStrength:
				member.strength -= 1
				updateUpgradeValues()
		if button.is_in_group("critRate"):
			if member.critRate > baseCritRate:
				member.critRate -= 0.5
				updateUpgradeValues()
		if button.is_in_group("critDamage"):
			if member.critDamage > baseCritDamage:
				member.critDamage -= 0.1
				updateUpgradeValues()
		if button.is_in_group("ultRegen"):
			if member.ultRegen > baseUltRegen:
				member.ultRegen -= 1
				updateUpgradeValues()
		if button.is_in_group("cooldown"):
			if member.cooldown > baseCooldown:
				member.cooldown += 0.2
				updateUpgradeValues()
				
func updateUpgradeValues():
	upgradePoints += 1
	upgradePointText.text = "Upgrade Points " + str(upgradePoints)
	updateAllValues(member.strength, member.critRate, member.critDamage, member.ultRegen, member.cooldown)


