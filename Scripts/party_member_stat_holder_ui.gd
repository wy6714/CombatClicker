extends Control

@onready var strengthVal = $StatMenuItems/StrengthPoints
@onready var critRateVal = $StatMenuItems/CritRatePoints
@onready var critDamageVal = $StatMenuItems/CritDamagePoints
@onready var ultRegenVal = $StatMenuItems/UltRegenPoints
@onready var cooldownVal = $StatMenuItems/CooldownPoints
@onready var statusRateVal = $StatMenuItems/StatusRatePoints

@onready var upgradePointText = $StatMenuItems/UpgradePoints
@onready var upgradePointCostText = $StatMenuItems/BuyUpgrade/UpgradePointsCost

@onready var strengthText = $StatMenuItems/STR
@onready var critRateText = $StatMenuItems/CrR
@onready var critDamageText = $StatMenuItems/CrD
@onready var ultRegenText = $StatMenuItems/UR
@onready var cooldownText = $StatMenuItems/CD
@onready var statusRateText = $StatMenuItems/SR
@onready var nameText = $StatMenuItems/Name

@onready var expRate = $StatMenuItems/ExperienceRate
@onready var radiantRate = $StatMenuItems/RadiantRate
@onready var enemyManager = get_node("/root/Main/EnemyManager")

var member
var currentlyDisplayingMember
var currentElement = ""
var open = false
@onready var player = get_node("/root/Main/Player")

@onready var disableAudio = $StatMenuItems/DisableAudio
@onready var disableAnim = $StatMenuItems/DisableAnimation
@onready var setAsInactive = $StatMenuItems/SetAsInactive

@onready var disableAudioButton = $StatMenuItems/DisableAudio/DisableAudioButton
@onready var disableAnimButton = $StatMenuItems/DisableAnimation/DisableAnimationButton
@onready var setAsInactiveButton = $StatMenuItems/SetAsInactive/SetAsInactiveButton
@onready var clickOffOverlay = $ClickOffOverlay

@onready var rightSelectionArrow = $StatMenuItems/RightSelectionArrow
@onready var leftSelectionArrow = $StatMenuItems/LeftSelectionArrow
@onready var menuJggleAnim = $StatHolderJiggle

# STAT CAPS
const MAX_STRENGTH: float = 100000.0
const MAX_CRIT_RATE: float = 100.0
const MAX_CRIT_DAMAGE: float = 100.0
const MAX_ULT_REGEN: float = 100.0
const MIN_COOLDOWN: float = 1.0
const MAX_STATUS_RATE: float = 100.0
const MAX_ULT_POTENCY: float = 1000.0

@export var memberUpgradePointScalar = 1.25
@export var memberUpgradePointCostCap = 99999.0

@onready var ultBonus = $"StatMenuItems/ULT BONUS"

func _ready():
	for button in get_tree().get_nodes_in_group("add_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, true))

	for button in get_tree().get_nodes_in_group("remove_upgrade"):
		button.pressed.connect(_on_upgrade_button_pressed.bind(button, false))

	if member != null:
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)

	for button in get_tree().get_nodes_in_group("ElementalButton"):
		if button is TextureButton:
			button.pressed.connect(
				Callable(self, "_on_elemental_button_pressed").bind(button)
			)

	# Hide ALL bonus labels when the scene starts.
	var bonusLabels = [
		$StatMenuItems/StrengthPoints/BonusBuffPointsSTR,
		$StatMenuItems/CritRatePoints/BonusBuffPointsCR,
		$StatMenuItems/CritDamagePoints/BonusBuffPointsCrD,
		$StatMenuItems/UltRegenPoints/BonusBuffPointsUR,
		$StatMenuItems/CooldownPoints/BonusBuffPointsCD,
		$StatMenuItems/StatusRatePoints/BonusBuffPointsSR,
	]

	for label in bonusLabels:
		label.text = ""
		label.visible = false

	ultBonus.visible = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currentlyDisplayingMember and currentlyDisplayingMember.is_in_group("Player"):
		var baseRadiantRate = 1  # Your base radiant rate
		var tempBoost = 0
		if enemyManager.tempRadiantBoostCounter > 0:
			tempBoost = enemyManager.tempRadiantBoost
		
		expRate.text = "Exp Rate: " + str(snapped(player.expMultiplier, 0.1)) + "x"
		radiantRate.text = "Radiant Rate: " + str(baseRadiantRate + tempBoost + enemyManager.permanentRadiantRate) + "%"

func updateAllValues(member):
	nameText.text = member.characterName

	# These controls are only for party members.
	disableAudio.visible = true
	disableAnim.visible = true
	setAsInactive.visible = true

	disableAudioButton.set_pressed_no_signal(member.muted)
	disableAnimButton.set_pressed_no_signal(member.animPaused)
	setAsInactiveButton.set_pressed_no_signal(member.disabled)

	cooldownText.visible = true
	cooldownVal.visible = true
	
	statusRateText.visible = true
	statusRateVal.visible = true
	
	expRate.visible = false
	radiantRate.visible = false
	
	strengthVal.text = str(member.strength)
	critRateVal.text = str(member.critRate)
	critDamageVal.text = str(member.critDamage)
	ultRegenVal.text = str(member.ultRegen)
	cooldownVal.text = str(member.cooldown)
	statusRateVal.text = str(member.statusRate)
	
	updateUltBonusVisibility(member)
	
	# Set all elemental buttons as inactive first.
	for btn in get_tree().get_nodes_in_group("ElementalButton"):
		btn.button_pressed = false
	
	if currentElement != null:
		match member.currentElement:
			"Fire":
				$StatMenuItems/FireButton.button_pressed = true
			"Water":
				$StatMenuItems/WaterButton.button_pressed = true
			"Wind":
				$StatMenuItems/WindButton.button_pressed = true
			"Earth":
				$StatMenuItems/EarthButton.button_pressed = true
			"Electric":
				$StatMenuItems/ElectricButton.button_pressed = true
			_:
				print("None are selected. This might be the player")
	
	# Party members actually set up their element.
	for btn in get_tree().get_nodes_in_group("ElementalButton"):
		btn.visible = true
	
# Updates all member values, but is invisible.	(Doesnt bring up UI)
func memberStatUpdate(member):
	nameText.text = member.characterName
	strengthVal.text = str(member.strength)
	critRateVal.text = str(member.critRate)
	critDamageVal.text = str(member.critDamage)
	ultRegenVal.text = str(member.ultRegen)
	cooldownVal.text = str(member.cooldown)
	statusRateVal.text = str(member.statusRate)
	
	
	updateUltBonusVisibility(member)
	
	# Set all elemental buttons as inactive, so that we can later set the only active button on.
	for btn in get_tree().get_nodes_in_group("ElementalButton"):
				btn.button_pressed = false
				
	match member.currentElement:
		"Fire":
			$StatMenuItems/FireButton.button_pressed = true
		"Water":
			$StatMenuItems/WaterButton.button_pressed = true
		"Wind":
			$StatMenuItems/WindButton.button_pressed = true
		"Earth":
			$StatMenuItems/EarthButton.button_pressed = true
		"Electric":
			$StatMenuItems/ElectricButton.button_pressed = true
		_:
			print("None are selected. I think this can be deleted then tbh")

func updateAllPlayerValues(player):
	
	nameText.text = player.characterName

	# These controls are only for party members.
	disableAudio.visible = false
	disableAnim.visible = false
	setAsInactive.visible = false
	
	strengthVal.text = str(player.strength)
	critRateVal.text = str(player.critRate)
	critDamageVal.text = str(player.critDamage)
	ultRegenVal.text = str(player.ultRegen)
	statusRateVal.text = str(player.statusRate)
	
	updateUltBonusVisibility(player, true)
			
	cooldownText.visible = false
	cooldownVal.visible = false
	
	# Only show rates for the player.
	expRate.visible = true
	radiantRate.visible = true
	
# Updates all player stats, but is invisible (doesnt bring up UI)		
func playerStatUpdate(player):
	
	nameText.text = player.characterName
	strengthVal.text = str(player.strength)
	critRateVal.text = str(player.critRate)
	critDamageVal.text = str(player.critDamage)
	ultRegenVal.text = str(player.ultRegen)
	statusRateVal.text = str(player.statusRate)
	
	updateUltBonusVisibility(player, true)
	
func _on_buy_upgrade_button_down():
	if(player.score >= member.upgradePointCost):
		player.transactionScoreUpdate(member.upgradePointCost * -1)
		member.upgradePoints += 1
		member.totalAccumulatedUpgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		member.upgradePointCost = min(
			member.upgradePointCost * memberUpgradePointScalar,
			memberUpgradePointCostCap
		)
		upgradePointCostText.text = str(member.upgradePointCost) + " points"
	
func _on_upgrade_button_pressed(button, is_add):
	if is_add:
		applyUpgrade(button)
	else:
		removeUpgrade(button)

func applyUpgrade(button):
	print("Applying upgrade from:", button.name)
	
	# Don't spend an upgrade point if the selected stat is already capped.
	if member.upgradePoints <= 0:
		return
	
	var upgraded := false
	
	if button.is_in_group("strength"):
		if member.strength < MAX_STRENGTH:
			member.strength = min(member.strength + 1.0, MAX_STRENGTH)
			upgraded = true
			upgradeTextColor(strengthText, member.strength, member.baseStrength)
			
	if button.is_in_group("critRate"):
		if member.critRate < MAX_CRIT_RATE:
			member.critRate = min(member.critRate + 0.5, MAX_CRIT_RATE)
			upgraded = true
			upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
			
	if button.is_in_group("critDamage"):
		if member.critDamage < MAX_CRIT_DAMAGE:
			member.critDamage = min(member.critDamage + 0.1, MAX_CRIT_DAMAGE)
			upgraded = true
			upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
			
	if button.is_in_group("ultRegen"):
		if member.ultRegen < MAX_ULT_REGEN:
			member.ultRegen = min(member.ultRegen + 0.5, MAX_ULT_REGEN)
			upgraded = true
			upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
			
	if button.is_in_group("cooldown"):
		if member.cooldown > MIN_COOLDOWN:
			member.cooldown = max(member.cooldown - 0.2, MIN_COOLDOWN)
			upgraded = true
			upgradeTextColorCooldown(cooldownText, member.cooldown, member.baseCooldown)
			
	if button.is_in_group("statusRate"):
		if member.isPlayer:
			if member.statusRate < MAX_STATUS_RATE:
				member.statusRate = min(member.statusRate + 0.2, MAX_STATUS_RATE)
				upgraded = true
		else:
			if member.statusRate < MAX_STATUS_RATE:
				member.statusRate = min(member.statusRate + 1.0, MAX_STATUS_RATE)
				upgraded = true
				
		if upgraded:
			upgradeTextColor(statusRateText, member.statusRate, member.baseStatusRate)
	
	# Only consume the upgrade point if an upgrade actually happened.
	if not upgraded:
		return
	
	member.upgradePoints -= 1
	upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
	
	if not member.isPlayer:
		updateAllValues(member)
	else:
		updateAllPlayerValues(member)
		
		player.strength = member.strength
		player.critRate = member.critRate
		player.critDamage = member.critDamage
		player.ultRegen = member.ultRegen
		player.statusRate = member.statusRate

func removeUpgrade(button):
	print("Removing upgrade from:", button.name)
	
	var removed := false
	
	if button.is_in_group("strength"):
		if member.strength > member.baseStrength:
			member.strength = max(member.strength - 1.0, member.baseStrength)
			removed = true
			upgradeTextColor(strengthText, member.strength, member.baseStrength)
			
	if button.is_in_group("critRate"):
		if member.critRate > member.baseCritRate:
			member.critRate = max(member.critRate - 0.5, member.baseCritRate)
			removed = true
			upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
			
	if button.is_in_group("critDamage"):
		if member.critDamage > member.baseCritDamage:
			member.critDamage = max(member.critDamage - 0.1, member.baseCritDamage)
			removed = true
			upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
			
	if button.is_in_group("ultRegen"):
		if member.ultRegen > member.baseUltRegen:
			member.ultRegen = max(member.ultRegen - 0.5, member.baseUltRegen)
			removed = true
			upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
			
	if button.is_in_group("cooldown"):
		if member.cooldown < member.baseCooldown:
			member.cooldown = min(member.cooldown + 0.2, member.baseCooldown)
			removed = true
			upgradeTextColorCooldown(cooldownText, member.cooldown, member.baseCooldown)
			
	if button.is_in_group("statusRate"):
		if member.statusRate > member.baseStatusRate:
			if member.isPlayer:
				member.statusRate = max(member.statusRate - 0.2, member.baseStatusRate)
			else:
				member.statusRate = max(member.statusRate - 1.0, member.baseStatusRate)
			
			removed = true
			upgradeTextColor(statusRateText, member.statusRate, member.baseStatusRate)
			
	if not removed:
		return
	
	updateUpgradeValues()
	
	if member.isPlayer:
		player.strength = member.strength
		player.critRate = member.critRate
		player.critDamage = member.critDamage
		player.ultRegen = member.ultRegen
		player.statusRate = member.statusRate
						
func updateUpgradeValues():
	if(!member.isPlayer):
		member.upgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		updateAllValues(member)
	else:
		member.upgradePoints += 1
		upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
		updateAllPlayerValues(member)

func upgradeTextColor(statText, stat, baseStat):
	var statDiff = stat - baseStat
	var colorIntensity = clamp(statDiff * 0.02, 0, 1)
	statText.modulate = Color(1.0 - colorIntensity, 1, 1.0 - colorIntensity, 1)
	
func upgradeTextColorCooldown(statText, stat, baseStat):
	var statDiff = baseStat - stat
	var colorIntensity = clamp(statDiff * 0.1, 0, 1)
	statText.modulate = Color(1.0 - colorIntensity, 1, 1.0 - colorIntensity, 1)

func updateMemberTextColors():
	upgradeTextColor(strengthText, member.strength, member.baseStrength)
	upgradeTextColor(critRateText, member.critRate, member.baseCritRate)
	upgradeTextColor(critDamageText, member.critDamage, member.baseCritDamage)
	upgradeTextColor(ultRegenText, member.ultRegen, member.baseUltRegen)
	if !(member.is_in_group("Player")):
		print("NOT A PLAYER> UHHHH")
		upgradeTextColor(cooldownText, member.cooldown, member.baseCooldown)
		upgradeTextColor(statusRateText, member.statusRate, member.baseStatusRate)
		print(member.characterName)

func _on_elemental_button_pressed(button: TextureButton):
	var selected = button.name
	var elementName = selected.replace("Button", "")
	
	# If the selected element is already active, toggle it off.
	if (member.currentElement == elementName):
		member.currentElement = "None"
		member.fire = false
		member.water = false
		member.wind = false
		member.earth = false
		member.electric = false
		button.button_pressed = false
		print("Current Element: ", member.currentElement)
		return
		
	else:
		
		# Select the element by first toggling off everything...
		for btn in get_tree().get_nodes_in_group("ElementalButton"):
			btn.button_pressed = false
			member.fire = false
			member.water = false
			member.wind = false
			member.earth = false
			member.electric = false
			
		#... and then applying the chosen element.
		match selected:
			"FireButton":
				member.fire = true
				member.currentElement = "Fire"
			"WaterButton":
				member.water = true
				member.currentElement = "Water"
			"WindButton":
				member.wind = true
				member.currentElement = "Wind"
			"EarthButton":
				member.earth = true
				member.currentElement = "Earth"
			"ElectricButton":
				member.electric = true
				member.currentElement = "Electric"
			_:
				member.currentElement = "None"
				
		button.button_pressed = true  # re-toggle only the selected

	print("Current element: ", member.currentElement)
			
func realTimeStatMenuUpdate():
	for teammate in get_tree().get_nodes_in_group("Buffable"):
		if(teammate.is_in_group("Player")):
			playerStatUpdate(teammate)
		else:
			memberStatUpdate(teammate)
			
	self.visible = true
	updateAllValues(currentlyDisplayingMember)
	upgradePointText.text = "Upgrade Points " + str(currentlyDisplayingMember.upgradePoints)
	upgradePointCostText.text = str(currentlyDisplayingMember.upgradePointCost) + " points"
	updateMemberTextColors()
	nameText.text = currentlyDisplayingMember.characterName
	
func statOpen():
	clickOffOverlay.visible = true
	$PanelFade.play("fade")
	$StatMenuEntryAndExit.play("open")
	randomizePitch($MenuOpen)

	# Don't leave the Stats button focused after opening with Enter.
	get_viewport().gui_release_focus()
	
	updateSelectionArrowVisibility()
	
func statClose():
	clickOffOverlay.visible = false
	$PanelFade.play("fadeOut")
	$StatMenuEntryAndExit.play("close")
	randomizePitch($MenuClose)
	# Return to white
	for member in get_tree().get_nodes_in_group("UIMember"):
		member.charUI1.modulate = Color.WHITE
		member.charUI2.modulate = Color.WHITE

func _on_close_button_button_down():
	# Remember who is currently being displayed.
	var closedMember = currentlyDisplayingMember
	
	# Release keyboard focus.
	get_viewport().gui_release_focus()
	
	# Make absolutely sure the Stats button isn't left in a pressed/focused state.
	if closedMember != null:
		closedMember.statsButton.set_pressed_no_signal(false)
		closedMember.statsButton.release_focus()
	
	statClose()
	
	if currentlyDisplayingMember != null:
		currentlyDisplayingMember.open = false
	
	member = null
	currentlyDisplayingMember = null
	open = false

	# Re-enable party member selection controls.
	for uiMember in get_tree().get_nodes_in_group("UIMember"):
		uiMember.nameLine.mouse_filter = Control.MOUSE_FILTER_STOP
		uiMember.statsButton.mouse_filter = Control.MOUSE_FILTER_STOP
		
func randomizePitch(audio):
	var rng = randf_range(0.7, 1.3)
	audio.pitch_scale = rng
	audio.play()
	
func _on_disable_audio_button_toggled(button_pressed):
	if currentlyDisplayingMember == null:
		return

	currentlyDisplayingMember.muted = button_pressed

	print(
		currentlyDisplayingMember.characterName,
		" muted: ",
		currentlyDisplayingMember.muted
	)

func _on_disable_animation_button_toggled(button_pressed):
	if currentlyDisplayingMember == null:
		return

	currentlyDisplayingMember.animPaused = button_pressed

	print(
		currentlyDisplayingMember.characterName,
		" animations paused: ",
		currentlyDisplayingMember.animPaused
	)
	
func _on_set_as_inactive_button_toggled(button_pressed):
	if currentlyDisplayingMember == null:
		return

	currentlyDisplayingMember.disabled = button_pressed

	print(
		currentlyDisplayingMember.characterName,
		" disabled: ",
		currentlyDisplayingMember.disabled
	)

func _on_click_off_overlay_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("CLICK OFF OVERLAY WORKS")
			_on_close_button_button_down()

func _input(event):
	if !open:
		return
	
	if currentlyDisplayingMember == null:
		return
	
	if event is InputEventKey and event.pressed and !event.echo:
		
		if event.physical_keycode == KEY_LEFT or event.physical_keycode == KEY_A:
			cycleDisplayedMember(-1)
			get_viewport().set_input_as_handled()
			
		elif event.physical_keycode == KEY_RIGHT or event.physical_keycode == KEY_D:
			cycleDisplayedMember(1)
			get_viewport().set_input_as_handled()

func cycleDisplayedMember(direction):
	
	
	var accessibleMembers = getAccessibleMembers()
	
	if accessibleMembers.is_empty():
		return
	
	menuJggleAnim.play("StatHolderJiggle")
	
	# Find the currently displayed character in the list.
	var currentIndex = accessibleMembers.find(currentlyDisplayingMember)
	
	if currentIndex == -1:
		# Something went wrong, so default to the first member.
		currentIndex = 0
	
	# Move left or right.
	currentIndex += direction
	
	# Wrap around at either end.
	if currentIndex < 0:
		currentIndex = accessibleMembers.size() - 1
	
	elif currentIndex >= accessibleMembers.size():
		currentIndex = 0
	
	var newMember = accessibleMembers[currentIndex]
	displayMember(newMember)


func getAccessibleMembers():
	var members = []
	
	for candidate in get_tree().get_nodes_in_group("Buffable"):
		
		# The Player is always accessible.
		if candidate.is_in_group("Player"):
			members.append(candidate)
		
		# Party members are accessible as long as they aren't inactive.
		elif candidate.get("disabled") != true:
			members.append(candidate)
	
	return members

func updateSelectionArrowVisibility():
	var accessibleMembers = getAccessibleMembers()
	
	# We always keep the arrows visible so the player
	# can see what they are for.
	var canSwitchMembers = accessibleMembers.size() > 1
	
	rightSelectionArrow.disabled = !canSwitchMembers
	leftSelectionArrow.disabled = !canSwitchMembers
	
	# Gray them out when they are disabled.
	if canSwitchMembers:
		rightSelectionArrow.modulate = Color.WHITE
		leftSelectionArrow.modulate = Color.WHITE
	else:
		rightSelectionArrow.modulate = Color(0.5, 0.5, 0.5, 1.0)
		leftSelectionArrow.modulate = Color(0.5, 0.5, 0.5, 1.0)
		
		# Don't let a disabled arrow keep keyboard focus.
		rightSelectionArrow.release_focus()
		leftSelectionArrow.release_focus()
		

func displayMember(newMember):
	# Keep track of the new character.
	currentlyDisplayingMember = newMember
	member = newMember
	
	# Update the stat menu depending on whether this is the Player
	# or a normal party member.
	if newMember.is_in_group("Player"):
		updateAllPlayerValues(newMember)
	else:
		updateAllValues(newMember)
	
	# Update the shared UI elements.
	upgradePointText.text = "Upgrade Points " + str(newMember.upgradePoints)
	upgradePointCostText.text = str(newMember.upgradePointCost) + " points"
	updateMemberTextColors()
	if newMember.is_in_group("Player") and newMember.has_method("getDisplayName"):
		nameText.text = newMember.getDisplayName()
	else:
		nameText.text = newMember.characterName
	
	updateSelectionArrowVisibility()

func _on_right_selection_arrow_button_down():
	cycleDisplayedMember(1)

func _on_left_selection_arrow_button_down():
	cycleDisplayedMember(-1)

func updateUltBonusVisibility(target, is_player: bool = false):
	# Get the bonus labels.
	var strengthBonus = $StatMenuItems/StrengthPoints/BonusBuffPointsSTR
	var critRateBonus = $StatMenuItems/CritRatePoints/BonusBuffPointsCR
	var critDamageBonus = $StatMenuItems/CritDamagePoints/BonusBuffPointsCrD
	var ultRegenBonus = $StatMenuItems/UltRegenPoints/BonusBuffPointsUR
	var cooldownBonus = $StatMenuItems/CooldownPoints/BonusBuffPointsCD
	var statusRateBonus = $StatMenuItems/StatusRatePoints/BonusBuffPointsSR


	# Set text only when the corresponding bonus is greater than zero.
	strengthBonus.text = "+" + str(target.bonusStrength) if target.bonusStrength > 0 else ""
	critRateBonus.text = "+" + str(target.bonusCritRate) if target.bonusCritRate > 0 else ""
	critDamageBonus.text = "+" + str(target.bonusCritDamage) if target.bonusCritDamage > 0 else ""
	ultRegenBonus.text = "+" + str(target.bonusUltRegen) if target.bonusUltRegen > 0 else ""
	statusRateBonus.text = "+" + str(target.bonusStatusRate) if target.bonusStatusRate > 0 else ""

	# The player doesn't use Cooldown or Ultimate Potency bonuses.
	if is_player:
		cooldownBonus.text = ""
	else:
		cooldownBonus.text = "-" + str(target.bonusCooldown) if target.bonusCooldown > 0 else ""

	# Show only labels that actually contain a bonus.
	var bonusLabels = [
		strengthBonus,
		critRateBonus,
		critDamageBonus,
		ultRegenBonus,
		cooldownBonus,
		statusRateBonus
	]

	var hasVisibleBonus = false

	for label in bonusLabels:
		label.visible = not label.text.is_empty()

		if label.visible:
			hasVisibleBonus = true

	# Show the ULT BONUS heading only when a bonus is active.
	ultBonus.visible = hasVisibleBonus
