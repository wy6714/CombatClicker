extends Control

var normal_scale := Vector2(0.5, 0.5)
var hover_scale := Vector2(0.6, 0.6)

var _orig_scales := {}
var _orig_colors := {}

# Stores the currently active tween for each button
var _active_tweens := {}
#@onready var shopAnim = $AnimationPlayer

@export var recruitButtonColorHover: Color = Color(1.0, 0.88, 0.2, 1.0) # yellow
@export var recruitButtonColorPressed: Color = Color(0.85, 0.7, 0.1, 1.0)

@export var monstersButtonColorHover: Color = Color(0.3, 1.0, 0.7, 1.0)   # mint/teal
@export var monstersButtonColorPressed: Color = Color(0.15, 0.7, 0.5, 1.0)

@export var guideButtonColorHover: Color = Color(0.45, 0.65, 1.0, 1.0)     # blue
@export var guideButtonColorPressed: Color = Color(0.25, 0.45, 0.75, 1.0)

@export var settingsButtonColorHover: Color = Color(1.0, 0.6, 0.25, 1.0)   # orange
@export var settingsButtonColorPressed: Color = Color(0.75, 0.4, 0.1, 1.0)

@export var gambleButtonColorHover: Color
@export var gambleButtonColorPressed: Color

var hover_colors = {
	"WeaponStoreButton": Color(0.8, 0, 0),
	"HireStoreButton": Color(0.8, 0.8, 0.0),
	"LotteryStoreButton": Color(0, 0.8, 0),
	"RecruitButton": recruitButtonColorHover,
	"MONSTERS": monstersButtonColorHover,
	"GUIDE": guideButtonColorHover,
	"SETTINGS": settingsButtonColorHover,
	"GambleButton": gambleButtonColorHover	
}

var pressed_colors = {
	"WeaponStoreButton": Color(0.5, 0, 0),
	"HireStoreButton": Color(0.5, 0.5, 0.0),
	"LotteryStoreButton": Color(0, 0.5, 0),
	"RecruitButton": recruitButtonColorPressed,
	"MONSTERS": monstersButtonColorPressed,
	"GUIDE": guideButtonColorPressed,
	"SETTINGS": settingsButtonColorPressed,
	"GambleButton": gambleButtonColorPressed
}

var weapon_data = {
	"Sword1": {"type": "Sword", "id": 1, "price": 0, "bought": true},
	"Sword2": {"type": "Sword", "id": 2, "price": 150, "bought": false},
	"Sword3": {"type": "Sword", "id": 3, "price": 200, "bought": false},
	"Claymore1": {"type": "Claymore", "id": 1, "price": 300, "bought": false},
	"Claymore2": {"type": "Claymore", "id": 2, "price": 350, "bought": false},
	"Claymore3": {"type": "Claymore", "id": 3, "price": 400, "bought": false},
	"Drill1": {"type": "Drill", "id": 1, "price": 500, "bought": false},
	"Drill2": {"type": "Drill", "id": 2, "price": 600, "bought": false},
	"Drill3": {"type": "Drill", "id": 3, "price": 700, "bought": false},
}

var normal_color := Color(1, 1, 1)
var darkened_color := Color(0.7, 0.7, 0.7)

@onready var sword1 = $WeaponStoreMenu/Sword1
@onready var mainStoreMenu = $MainStoreMenu
@onready var weaponStoreMenu = $WeaponStoreMenu
@onready var hireStoreMenu = $MainStoreMenu/HireStoreMenu
@onready var lotteryStoreMenu = $LotteryStore

@onready var weaponDatabase = get_node("/root/Main/Weapon")

var equippedWeapons = {
	"left": null,
	"right": null
}
@onready var initialWeapon = $WeaponStoreMenu/Sword1
@onready var player = get_node("/root/Main/Player")
@onready var recruitmentManager = get_node("/root/Main/shop/RecruitPartyMember")
@onready var partyManager = get_node("/root/Main/PartyMemberHolder")
@onready var playerStats = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")
@onready var settings = get_node("/root/Main/Settings")
@onready var guide = get_node("/root/Main/Guide")

@onready var playerCostLabel = $MainStoreMenu/HireStoreMenu/CharacterListContents/PlayerUpgrade/Cost
@onready var upgradePointFeedbackPopup = preload("res://Scenes/PlusOneUpgradePoint.tscn")
@export var memberUpgradePointScalar = 1.25
@export var memberUpgradePointCostCap = 99999.0

@onready var spotlight = $Spotlight
@onready var spotlightAnim = $SpotlightAnim

@onready var player_monster_list = get_node("/root/Main/Player/PlayerMonsterList/Control/MonsterPanelItems/GridContainer")
@onready var playerMonsterListScript = get_node("/root/Main/Player/PlayerMonsterList")

@onready var characterList = $MainStoreMenu/HireStoreMenu/CharacterListContents
var scrollPosition := 0
const scrollSpeed := 30.0

@onready var navUpButton = $"MainStoreMenu/HireStoreMenu/CharacterListPanelX/NavTriangleIcon(Up)"
@onready var navDownButton = $"MainStoreMenu/HireStoreMenu/CharacterListPanelX/NavTriangleIcon(Down)"

@onready var settingsButton = $MainStoreMenu/HireStoreMenu/SETTINGS

# Stored reference to the recruit button itself, found via the "recruit" group
# during connect_button_tree. Used to disable/re-enable it while the
# recruit animation is in flight, preventing the rapid-click double-trigger bug.
var recruitButton: BaseButton = null
var gambleButton: BaseButton = null

# True only while a recruit cutscene (spotlight fade + member rise) is in
# flight AND hasn't been skipped yet. Guarantees skipRecruitCutscene()'s
# actual skip logic runs exactly once per recruit, no matter how many times
# Enter gets pressed — previously, repeated presses could each re-enter the
# skip logic (since it only checked recruitButton.disabled, which doesn't
# reliably reflect "already skipped"), corrupting tween/animation state.
var cutsceneSkippable: bool = false
@onready var gamblePanel = $GamblePanel

func _ready():
	# Start off with a sword equipped
	equip_weapon(initialWeapon, "left", "Sword1")

	getButtonColors()
	updateWeaponPrices()
	updateRecruitmentPrices()

	# One hookup path only: recursive.
	# This catches nested buttons like Recruit / MONSTERS / GUIDE / SETTINGS
	# and avoids duplicate signal connections.
	connect_button_tree(mainStoreMenu)
	connect_button_tree(weaponStoreMenu)
	connect_button_tree(hireStoreMenu)
	connect_button_tree(lotteryStoreMenu)
	
	# Initialize scroll button states
	#update_scroll_button_states()
	
	# Manage party member cost label visibility (skip player)
	manage_cost_label_visibility()
	
	# Re-enable the recruit button exactly when the spotlight animation
	# actually finishes, instead of guessing a cooldown duration.
	spotlightAnim.animation_finished.connect(_on_spotlight_anim_finished)
	
	gamblePanel.modulate.a = 0.0
	gamblePanel.visible = false
	
	if gambleButton:
		if not gambleButton.mouse_entered.is_connected(_on_gamble_hover_entered):
			gambleButton.mouse_entered.connect(_on_gamble_hover_entered)
		if not gambleButton.mouse_exited.is_connected(_on_gamble_hover_exited):
			gambleButton.mouse_exited.connect(_on_gamble_hover_exited)

func connect_button_tree(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton and child.is_in_group("ui_button"):
			var enter_cb := Callable(self, "_on_button_mouse_entered").bind(child)
			var exit_cb := Callable(self, "_on_button_mouse_exited").bind(child)
			var down_cb := Callable(self, "_on_button_down").bind(child)
			var up_cb := Callable(self, "_on_button_up").bind(child)

			if not child.mouse_entered.is_connected(enter_cb):
				child.mouse_entered.connect(enter_cb)
			if not child.mouse_exited.is_connected(exit_cb):
				child.mouse_exited.connect(exit_cb)
			if not child.button_down.is_connected(down_cb):
				child.button_down.connect(down_cb)
			if not child.button_up.is_connected(up_cb):
				child.button_up.connect(up_cb)

			_orig_scales[child] = child.scale
			_orig_colors[child] = child.modulate

		# Recruit button action hookup.
		if child.is_in_group("recruit"):
			recruitButton = child
			var recruit_cb := Callable(self, "getNewPartyMember")
			if not child.button_down.is_connected(recruit_cb):
				child.button_down.connect(recruit_cb)
		
		if child.is_in_group("gamble"):
			gambleButton = child
			
		# Weapon button hookup.
		if child.is_in_group("Weapons"):
			var weapon_cb := Callable(self, "select_weapon").bind(child.name)
			if not child.button_down.is_connected(weapon_cb):
				child.button_down.connect(weapon_cb)

		# Recurse through all descendants.
		connect_button_tree(child)

func _process(delta):
	pass

func _on_button_mouse_entered(btn: BaseButton):
	var hover_color: Color
	if btn.is_in_group("unlocked"):
		hover_color = Color(1, 1, 1)
	else:
		hover_color = hover_colors.get(btn.name, _orig_colors[btn])

	var normal = _orig_scales[btn]
	var hover = normal * 1.1

	var tw = btn.create_tween()
	tw.tween_property(btn, "scale", hover, 0.15)
	tw.tween_property(btn, "modulate", hover_color, 0.15)

	_active_tweens[btn] = tw
	playHoverSE()

func _on_button_mouse_exited(btn: BaseButton):
	var target_color: Color

	if btn.is_in_group("unlocked"):
		target_color = Color(1, 1, 1)
	else:
		target_color = _orig_colors.get(btn, normal_color)

	var normal_scale = _orig_scales[btn]
	var tw = btn.create_tween()
	tw.tween_property(btn, "scale", normal_scale, 0.15)
	tw.tween_property(btn, "modulate", target_color, 0.15)

func _on_button_down(button: BaseButton):
	var target_color = pressed_colors.get(button.name, normal_color)
	button.modulate = target_color

func _on_button_up(button: BaseButton):
	if button.is_in_group("unlocked"):
		button.modulate = Color(1, 1, 1)
	else:
		var orig_color = _orig_colors.get(button, normal_color)
		button.modulate = orig_color

func mainShopButtonAnim():
	pass

func getButtonName(button: BaseButton):
	if !button:
		print("um")
		return

# Choosing a weapon
func select_weapon(weapon_name: String):
	var weapon_info = weapon_data.get(weapon_name)

	if weapon_info:
		if weapon_info["bought"]:
			print("Selected:", weapon_info["type"], "ID:", weapon_info["id"])
		else:
			var cost = weapon_info["price"]
			if player.score >= cost:
				player.transactionScoreUpdate(cost * -1)
				weapon_info["bought"] = true
				print(weapon_name, "purchased! Remaining Gold:", player.score)
			else:
				print("Not enough gold to buy", weapon_name)
				return
	else:
		print("Unknown weapon selected:", weapon_name)
		return

	updateWeaponPrices()

	var weapons = get_tree().get_nodes_in_group("Weapons")
	var currentWeapon = null
	for node in weapons:
		if node.name == weapon_name:
			currentWeapon = node
			break

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		equip_weapon(currentWeapon, "left", weapon_name)
		print("LEFT")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		equip_weapon(currentWeapon, "right", weapon_name)
		print("RIGHT")

func equip_weapon(weapon_button: TextureButton, mouse_button: String, weapon_name: String):
	var left_symbol = weapon_button.get_node("Left Equip")
	var right_symbol = weapon_button.get_node("Right Equip")

	if equippedWeapons[mouse_button]:
		var previous_button = equippedWeapons[mouse_button]
		var previous_symbol = previous_button.get_node(
			"Left Equip" if mouse_button == "left" else "Right Equip"
		)
		previous_symbol.hide()

	equippedWeapons[mouse_button] = weapon_button
	if mouse_button == "left":
		left_symbol.show()
		right_symbol.hide()
		if equippedWeapons["right"] == equippedWeapons["left"]:
			equippedWeapons["right"] = null

		var stats = weaponDatabase.weapon_stats[weapon_name]
		var strBon = stats["strength"]
		var critRateBon = stats["crit_rate"]
		var critDamageBon = stats["crit_damage"]
		var ultRegenBon = stats["ult_regen"]
		var statusRate = stats["status_rate"]

		player.setLeftWeaponBonus(strBon, critRateBon, critDamageBon, ultRegenBon, statusRate)

	elif mouse_button == "right":
		right_symbol.show()
		left_symbol.hide()
		if equippedWeapons["left"] == equippedWeapons["right"]:
			equippedWeapons["left"] = null

		var stats = weaponDatabase.weapon_stats[weapon_name]
		var strBon = stats["strength"]
		var critRateBon = stats["crit_rate"]
		var critDamageBon = stats["crit_damage"]
		var ultRegenBon = stats["ult_regen"]
		var elements = stats["elements"]
		var statusRate = stats["status_rate"]

		player.setRightWeaponBonus(strBon, critRateBon, critDamageBon, ultRegenBon, elements, statusRate)

func getWeaponType(weapon_button: TextureButton) -> String:
	if weapon_button.name.begins_with("Sword"):
		return "Sword"
	elif weapon_button.name.begins_with("Claymore"):
		return "Claymore"
	elif weapon_button.name.begins_with("Drill"):
		return "Drill"
	else:
		return "Unknown"

func performWeaponAction(mouse_button: String):
	var weapon = equippedWeapons[mouse_button]
	if weapon == null:
		print("No weapon equipped for", mouse_button, "click.")
		return

	var weaponType = getWeaponType(weapon)

	match weaponType:
		"Sword":
			player.activeHand = mouse_button
			player.dealDamage()
		"Claymore":
			player.activeHand = mouse_button
			player.determineClaymoreButton(mouse_button)
		"Drill":
			player.activeHand = mouse_button
			player.drilling(mouse_button)
		_:
			print("No action configured for weapon type:", weaponType)

func getNewPartyMember():
	# Ignore clicks while a recruit animation is still in flight.
	# Without this, rapid clicks can restart SpotlightFade mid-fade,
	# leaving the spotlight stuck visible and blocking input permanently.
	if recruitButton.disabled:
		return

	if recruitmentManager.newPartyMember():
		recruitButton.disabled = true
		cutsceneSkippable = true
		spotlight.visible = true
		spotlightAnim.play("SpotlightFade")

func _on_spotlight_anim_finished(anim_name: StringName):
	print("Spotlight anim finished signal fired: ", anim_name)
	if anim_name == "SpotlightFade":
		finishRecruitCutscene()

func updateWeaponPrices():
	for button in weaponStoreMenu.get_children():
		if button.is_in_group("Weapons"):
			var weapon_info = weapon_data.get(button.name)
			if weapon_info:
				var label = button.get_node("Cost")
				label.text = str(weapon_info["price"])
				if weapon_info["bought"] == true:
					label.visible = false

func updateRecruitmentPrices():
	for button in hireStoreMenu.get_children():
		if button.is_in_group("recruit"):
			var hireButton = button
			if hireButton:
				var label = hireButton.get_node("Cost")
				label.text = str(recruitmentManager.partyMemberCost)

func getButtonColors():
	hover_colors = {
		"WeaponStoreButton": Color(0.8, 0, 0),
		"HireStoreButton": Color(0.8, 0.8, 0),
		"LotteryStoreButton": Color(0, 0.8, 0),
		"RecruitButton": recruitButtonColorHover,
		"MONSTERS": monstersButtonColorHover,
		"GUIDE": guideButtonColorHover,
		"SETTINGS": settingsButtonColorHover,
		"GambleButton": gambleButtonColorHover
	}

	pressed_colors = {
		"WeaponStoreButton": Color(0.5, 0, 0),
		"HireStoreButton": Color(0.5, 0.5, 0),
		"LotteryStoreButton": Color(0, 0.5, 0),
		"RecruitButton": recruitButtonColorPressed,
		"MONSTERS": monstersButtonColorPressed,
		"GUIDE": guideButtonColorPressed,
		"SETTINGS": settingsButtonColorPressed,
		"GambleButton": gambleButtonColorPressed
	}

func manage_cost_label_visibility():
	for button in characterList.get_children():
		# Skip the PlayerUpgrade button
		if button.name == "PlayerUpgrade":
			continue
		
		if button is BaseButton:
			var cost_label = button.get_node_or_null("Cost")
			if cost_label:
				# Show if unlocked, hide if locked
				if button.is_in_group("unlocked"):
					cost_label.visible = true
				else:
					cost_label.visible = false

func updateUnlockedButton():
	for button in mainStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			if button.is_in_group("unlocked"):
				_orig_colors[button] = Color.WHITE
				hover_colors.erase(button.name)
				pressed_colors.erase(button.name)
	
	# Update cost label visibility for party member buttons only
	manage_cost_label_visibility()

func playerMemberUpgradeButton():
	if player.score >= playerStats.upgradePointCost:
		playerStats.upgradePoints += 1
		player.score -= playerStats.upgradePointCost
		player.scoreNumber.text = str(player.score)
		
		playerStats.upgradePointCost = min(
			round(playerStats.upgradePointCost * memberUpgradePointScalar / 50.0) * 50,
			 memberUpgradePointCostCap
		)
		
		playerCostLabel.text = str(playerStats.upgradePointCost)

		var popup := upgradePointFeedbackPopup.instantiate()
		popup.global_position = playerStats.upgradePointFeedbackLocation.global_position
		get_tree().current_scene.add_child(popup)

		var start_pos = popup.global_position
		var end_pos = start_pos + Vector2(20, -100)

		var tween := create_tween()
		tween.tween_property(
			popup,
			"global_position",
			end_pos,
			0.7
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		playMemberUpgradeSE()
	else:
		print("Player doesnt have enough money..")
		playNotEnoughMoneySE()

func playMemberUpgradeSE():
	$ShopUIAudio/MemberUpgrade.play()
	print("hi (upgrade)")

func playHoverSE():
	var rng = randf_range(0.9, 1.1)
	$ShopUIAudio/Hover.pitch_scale = rng
	$ShopUIAudio/Hover.play()
	print("hi (hover)")

func playNotEnoughMoneySE():
	$ShopUIAudio/NotEnoughMoney.play()
	print("hi (brokie)")

func _on_monsters_button_down():
	playerMonsterListScript.uiSlideIn()
	player_monster_list.populate_monster_list()
	
func newCaptureBounce():
	$MainStoreMenu/HireStoreMenu/MONSTERS/NewCaptureAnim.play("newCaptureLabelBounce")

#func _on_nav_triangle_icon_up_button_down():
	#scrollPosition += scrollSpeed
	#scrollPosition = clamp(scrollPosition, -max_scroll(), 0)
	#characterList.position.y = scrollPosition
	#update_scroll_button_states()

#func _on_nav_triangle_icon_down_button_down():
	#scrollPosition -= scrollSpeed
	#scrollPosition = clamp(scrollPosition, -max_scroll(), 0)
	#characterList.position.y = scrollPosition
	#update_scroll_button_states()

#func update_scroll_button_states():
	#if navUpButton:
	#	navUpButton.disabled = scrollPosition >= 0
	#if navDownButton:
	#	navDownButton.disabled = scrollPosition <= -max_scroll()

func _unhandled_input(event):
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#_on_nav_triangle_icon_up_button_down()
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#_on_nav_triangle_icon_down_button_down()
			
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		skipRecruitCutscene()

func finishRecruitCutscene():
	spotlightAnim.stop()
	$ShopUIAudio/Recruit.stop()

	spotlight.visible = false
	cutsceneSkippable = false

	if recruitButton:
		recruitButton.disabled = false
		
func skipRecruitCutscene():
	if not cutsceneSkippable:
		return

	print("Skip triggered")

	finishRecruitCutscene()

	if partyManager and partyManager.roster.size() > 0:
		var newest = partyManager.roster.back()

		if newest and newest.has_method("skipArise"):
			newest.skipArise()

#func max_scroll() -> float:
	#var bottom := 0.0

	#for child in characterList.get_children():
		#bottom = max(bottom, child.position.y + child.size.y)

	#var panel_height = $MainStoreMenu/HireStoreMenu/CharacterListPanel.size.y

	#return max(0.0, bottom - panel_height)

func _on_settings_button_down():
	settings.openMenu()

func _on_guide_button_down():
	guide.guideSlideIn()

func _on_gamble_hover_entered():
	gamblePanel.visible = true
	var tw = gamblePanel.create_tween()
	tw.tween_property(gamblePanel, "modulate:a", 1.0, 0.2)

func _on_gamble_hover_exited():
	if not gamblePanel.isGambling:
		var tw = gamblePanel.create_tween()
		tw.tween_property(gamblePanel, "modulate:a", 0.0, 0.2)
		tw.tween_callback(func(): gamblePanel.visible = false)

func _on_gamble_button_button_down():
	gamblePanel.attemptGamble()

func updatePartyMemberName(member_number: int, display_name: String):
	var button = get_node_or_null(
		"MainStoreMenu/HireStoreMenu/CharacterListContents/PartyMemberUpgrade"
		+ str(member_number)
	)

	if button:
		var label = button.get_node("Label")
		label.text = display_name

func updatePlayerName(display_name: String):
	var button = get_node_or_null(
		"MainStoreMenu/HireStoreMenu/CharacterListContents/PlayerUpgrade"
	)
	
	if button:
		var label = button.get_node("Label")
		
		if display_name.strip_edges().is_empty():
			label.text = "You"
		else:
			label.text = display_name
