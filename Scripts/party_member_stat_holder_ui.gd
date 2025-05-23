extends Control

@onready var strengthVal = $StrengthPoints
@onready var critRateVal = $CritRatePoints
@onready var critDamageVal = $CritDamagePoints
@onready var ultRegenVal = $UltRegenPoints
@onready var cooldownVal = $CooldownPoints

@onready var upgradePointText = $UpgradePoints
@onready var upgradePointCostText = $BuyUpgrade/UpgradePointsCost

@onready var strengthText = $STR
@onready var critRateText = $CrR
@onready var critDamageText = $CrD
@onready var ultRegenText = $UR
@onready var cooldownText = $CD
@onready var cooldownPoints = $CooldownPoints
@onready var nameText = $Name


var member
@onready var player = get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("add_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, true))

	for button in get_tree().get_nodes_in_group("remove_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, false))
		
	if(member != null):
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateAllValues(strength, critRate, critDamage, ultRegen, cooldown):
	cooldownText.visible = true
	cooldownPoints.visible = true
	
	strengthVal.text = str(strength)
	critRateVal.text = str(critRate)
	critDamageVal.text = str(critDamage)
	ultRegenVal.text = str(ultRegen)
	cooldownVal.text = str(cooldown)
	
	
	
	
	
func updateAllPlayerValues(strength, critRate, critDamage, ultRegen):
	strengthVal.text = str(strength)
	critRateVal.text = str(critRate)
	critDamageVal.text = str(critDamage)
	ultRegenVal.text = str(ultRegen)
	
	cooldownText.visible = false
	cooldownPoints.visible = false
	
	

	
func _on_buy_upgrade_button_down():
	if(player.score >= member.upgradePointCost):
		player.transactionScoreUpdate(member.upgradePointCost * -1)
		member.upgradePoints += 1
		member.totalAccumulatedUpgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		member.upgradeCostMultiplier += 0.1
		member.upgradePointCost *= member.upgradeCostMultiplier
		upgradePointCostText.text = str(member.upgradePointCost) + " points"
		print(str(member.totalAccumulatedUpgradePoints))
	
func _on_upgrade_button_pressed(button, is_add):
	if is_add:
		applyUpgrade(button)
	else:
		removeUpgrade(button)

func applyUpgrade(button):
	print("Applying upgrade from:", button.name)
	
	if(member.upgradePoints > 0):
		if button.is_in_group("strength"):
			member.strength += 1
			upgradeTextColor(strengthText, member.strength, member.baseStrength)
		if button.is_in_group("critRate"):
			member.critRate += 0.5
			upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
		if button.is_in_group("critDamage"):
			member.critDamage += 0.1
			upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
		if button.is_in_group("ultRegen"):
			member.ultRegen += 1
			upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
		if button.is_in_group("cooldown"):
			member.cooldown -= 0.2
			upgradeTextColor(cooldownText, member.cooldown, member.baseCooldown)
			
		member.upgradePoints -= 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		if(!member.isPlayer):
			updateAllValues(member.strength, member.critRate, member.critDamage, member.ultRegen, member.cooldown)
		else:
			updateAllPlayerValues(member.strength, member.critRate, member.critDamage, member.ultRegen)
			player.strength = member.strength
			player.critRate = member.critRate
			player.critDamage = member.critDamage
			player.energyRecharge = member.ultRegen


func removeUpgrade(button):
	print("Removing upgrade from:", button.name)
	print("STRENGTH:", str(member.strength), "MEMBER BASE STRENGTH: ",  str(member.baseStrength))
	if(member.upgradePoints < member.totalAccumulatedUpgradePoints):
		if button.is_in_group("strength"):
			if member.strength > member.baseStrength:
				member.strength -= 1
				updateUpgradeValues()
				upgradeTextColor(strengthText, member.strength, member.baseStrength)
		if button.is_in_group("critRate"):
			if member.critRate > member.baseCritRate:
				member.critRate -= 0.5
				updateUpgradeValues()
				upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
		if button.is_in_group("critDamage"):
			if member.critDamage > member.baseCritDamage:
				member.critDamage -= 0.1
				updateUpgradeValues()
				upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
		if button.is_in_group("ultRegen"):
			if member.ultRegen > member.baseUltRegen:
				member.ultRegen -= 1
				updateUpgradeValues()
				upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
		if button.is_in_group("cooldown"):
			if member.cooldown > member.baseCooldown:
				member.cooldown += 0.2
				updateUpgradeValues()
				upgradeTextColor(cooldownText, member.cooldown, member.baseCooldown)
				
func updateUpgradeValues():
	if(!member.isPlayer):
		member.upgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		updateAllValues(member.strength, member.critRate, member.critDamage, member.ultRegen, member.cooldown)
	else:
		member.upgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		updateAllPlayerValues(member.strength, member.critRate, member.critDamage, member.ultRegen)

func upgradeTextColor(statText, stat, baseStat):
	var statDiff = stat - baseStat
	var colorIntensity = clamp(statDiff * 0.02, 0, 1)
	statText.modulate = Color(1.0 - colorIntensity, 1, 1.0 - colorIntensity, 1)

func updateMemberTextColors():
	upgradeTextColor(strengthText, member.strength, member.baseStrength)
	upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
	upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
	upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
	if(!member.player):
		upgradeTextColor(cooldownText, member.cooldown, member.baseCooldown)
	
	


