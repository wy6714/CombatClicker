extends Control

var normal_scale := Vector2(0.5, 0.5)
var hover_scale := Vector2(0.6, 0.6)

var _orig_scales := {}
var _orig_colors := {}

# Stores the currently active tween for each button
var _active_tweens: = {}
@onready var shopAnim = $AnimationPlayer

@export var recruitButtonColorHover: Color = Color(1,1,1,1)
@export var recruitButtonColorPressed: Color = Color(1,1,1,1)

var hover_colors = {
	"WeaponStoreButton": Color(0.8, 0, 0),
	"HireStoreButton": Color(0.8, 0.8, 0.0),
	"LotteryStoreButton": Color(0, 0.8, 0),
	"RecruitButton": recruitButtonColorHover
}

var pressed_colors = {
	"WeaponStoreButton": Color(0.5, 0, 0),
	"HireStoreButton": Color(0.5, 0.5, 0.0),
	"LotteryStoreButton": Color(0, 0.5, 0),
	"RecruitButton": recruitButtonColorPressed
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

var normal_color := Color(1, 1, 1)  # Default white
var darkened_color := Color(0.7, 0.7, 0.7)  # Slightly darker version of white (you can adjust this)

@onready var sword1 = $WeaponStoreMenu/Sword1
@onready var mainStoreMenu = $MainStoreMenu
@onready var weaponStoreMenu = $WeaponStoreMenu
@onready var hireStoreMenu = $HireStoreMenu
@onready var lotteryStoreMenu = $LotteryStore

@onready var weaponDatabase = get_node("/root/Main/Weapon")

var equippedWeapons = {
	"left": null,
	"right": null
}
@onready var initialWeapon = $WeaponStoreMenu/Sword1
@onready var player = get_node("/root/Main/Player")
@onready var recruitmentManager = get_node("/root/Main/shop/RecruitPartyMember")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Start off with a sword equipped
	equip_weapon(initialWeapon, "left", "Sword1")
	
	getButtonColors()
	updateWeaponPrices()
	updateRecruitmentPrices()
	
	for button in mainStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
			_orig_scales[button] = button.scale
			_orig_colors[button] = button.modulate
			
		if button.is_in_group("mainUI"):
			button.connect("button_down", Callable(self, "mainShopButtonAnim"))
			button.connect("button_down", Callable(self, "getButtonName").bind(button))
	
	for button in weaponStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
			_orig_scales[button] = button.scale
			_orig_colors[button] = button.modulate
		if button.is_in_group("back_button"):
			button.connect("button_down", Callable(self, "returnToMain").bind("Weapon"))
			
	for button in hireStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
			_orig_scales[button] = button.scale
			_orig_colors[button] = button.modulate
		if button.is_in_group("back_button"):
			button.connect("button_down", Callable(self, "returnToMain").bind("Hire"))
		if button.is_in_group("recruit"):
			button.connect("button_down", Callable(self, "getNewPartyMember"))
	
	for button in lotteryStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
			_orig_scales[button] = button.scale
			_orig_colors[button] = button.modulate
		if button.is_in_group("back_button"):
			button.connect("button_down", Callable(self, "returnToMain").bind("Lottery"))
			
	# Get all weapon buttons
	for button in weaponStoreMenu.get_children():
		if button.is_in_group("Weapons"):
			button.connect("button_down", Callable(self, "select_weapon").bind(button.name))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_mouse_entered(btn: TextureButton):
	# determine the color we should hover to
	var hover_color: Color
	if btn.is_in_group("unlocked"):
		hover_color = Color(1, 1, 1)
	else:
		hover_color = hover_colors.get(btn.name, _orig_colors[btn])

	# determine the scale we should hover to
	var normal = _orig_scales[btn]
	var hover  = normal * 1.1

	# tween both scale and color
	var tw = btn.create_tween()
	tw.tween_property(btn, "scale",   hover,       0.15)
	tw.tween_property(btn, "modulate", hover_color, 0.15)

	_active_tweens[btn] = tw

func _on_button_mouse_exited(btn: TextureButton):
	var target_color: Color
	
	if btn.is_in_group("unlocked"):
		target_color = Color(1, 1, 1)
	else:
		target_color = _orig_colors.get(btn, normal_color)

	var normal_scale = _orig_scales[btn]
	var tw = btn.create_tween()
	tw.tween_property(btn, "scale", normal_scale, 0.15)
	tw.tween_property(btn, "modulate", target_color, 0.15)
	
# Called when the button is pressed (darken effect)
func _on_button_down(button: TextureButton):
	var target_color = pressed_colors.get(button.name, normal_color)
	button.modulate = target_color

# Button released (brighten)
func _on_button_up(button: TextureButton):
 # If this button is “unlocked,” always go back to white
	if button.is_in_group("unlocked"):
		button.modulate = Color(1, 1, 1)
	else:
		# Otherwise restore whatever original color we saved
		var orig_color = _orig_colors.get(button, normal_color)
		button.modulate = orig_color
	
func mainShopButtonAnim():
	if !shopAnim.is_playing():
		shopAnim.play("MainMenuSlideDown")
	else:
		shopAnim.queue("MainMenuSlideDown")  # Waits for the current animation to finish before playing

func returnToMain(uiType: String):
	if(uiType == "Weapon"):
		if(shopAnim.is_playing()):
			shopAnim.queue("WeaponMenuSlideDown")
		else:
			shopAnim.play("WeaponMenuSlideDown")
			
	if(uiType == "Hire"):
		if(shopAnim.is_playing()):
			shopAnim.queue("HireMenuSlideDown")
		else:
			shopAnim.play("HireMenuSlideDown")
	
	if(uiType == "Lottery"):
		if(shopAnim.is_playing()):
			shopAnim.queue("LotteryMenuSlideDown")
		else:
			shopAnim.play("LotteryMenuSlideDown")
	
	if shopAnim.is_playing():	
		shopAnim.queue("MainMenuSlideIn")
	else:
		shopAnim.play("MainMenuSlideIn")

func getButtonName(button: TextureButton):
	if !button:  # Safety check
		print("um")
		return
	
	match button.name:
		"WeaponStoreButton":
			if shopAnim.is_playing():
				shopAnim.queue("WeaponMenuSlideIn")
			else:
				shopAnim.play("WeaponMenuSlideIn")
			print("WEAPON")
		"HireStoreButton":
			if shopAnim.is_playing():
				shopAnim.queue("HireMenuSlideUp")
			else:
				shopAnim.play("HireMenuSlideUp")
		"LotteryStoreButton":
			if shopAnim.is_playing():
				shopAnim.queue("LotteryMenuSlideUp")
			else:
				shopAnim.play("LotteryMenuSlideUp")
		_:
			print("Unknown button clicked:", button.name)  # Debugging fallback

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
				return  # Stop here if we can't afford the weapon
	else:
		print("Unknown weapon selected:", weapon_name)
		return  # Stop if the weapon doesn't exist
	
	#UPDATE COST FOR A WEAPON THAT YOU JUST BOUGHT
	updateWeaponPrices()
	
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var currentWeapon = null
	for node in weapons:
		if node.name == weapon_name:
			currentWeapon = node
			break
			
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		equip_weapon(currentWeapon, "left", weapon_name)
		print("LEFT")
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		equip_weapon(currentWeapon, "right", weapon_name)
		print("RIGHT")

			
	# Function to handle equipping
func equip_weapon(weapon_button: TextureButton, mouse_button: String, weapon_name: String):
	# Get the Left and Right equip symbols
	var left_symbol = weapon_button.get_node("Left Equip")
	var right_symbol = weapon_button.get_node("Right Equip")

	# Unequip the previously equipped weapon for this mouse button
	if equippedWeapons[mouse_button]:
		var previous_button = equippedWeapons[mouse_button]
		var previous_symbol = previous_button.get_node(
			"Left Equip" if mouse_button == "left" else "Right Equip"
		)
		previous_symbol.hide()

	# Equip the new weapon
	equippedWeapons[mouse_button] = weapon_button
	if mouse_button == "left":
		left_symbol.show()
		right_symbol.hide()
		if(equippedWeapons["right"] == equippedWeapons["left"]):
			equippedWeapons["right"] = null
			
		var stats = weaponDatabase.weapon_stats[weapon_name]
		var strBon = stats["strength"]
		var critRateBon = stats["crit_rate"]
		var critDamageBon = stats["crit_damage"]
		var ultRegenBon = stats["ult_regen"]
		var elements = stats["elements"]
		var statusRate = stats["status_rate"]
		
		player.setLeftWeaponBonus(strBon, critRateBon, critDamageBon, ultRegenBon, elements, statusRate)
		
	elif mouse_button == "right":
		right_symbol.show()
		left_symbol.hide()
		if(equippedWeapons["left"] == equippedWeapons["right"]):
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
	# Example: Use the button's name to determine the weapon type
	if weapon_button.name.begins_with("Sword"):
		return "Sword"
	elif weapon_button.name.begins_with("Claymore"):
		return "Claymore"
	elif weapon_button.name.begins_with("Drill"):
		return "Drill"
	else:
		return "Unknown"

func performWeaponAction(mouse_button: String):
	# Get the equipped weapon for the specified mouse button
	var weapon = equippedWeapons[mouse_button]
	if weapon == null:
		print("No weapon equipped for", mouse_button, "click.")
		return

	# Determine the weapon type
	var weaponType = getWeaponType(weapon)
	
	# Perform the action based on the weapon type
	match weaponType:
		"Sword":
			player.activeHand = mouse_button
			player.dealDamage()  # Sword's action for any button
		"Claymore":
			player.activeHand = mouse_button
			player.determineClaymoreButton(mouse_button)
		"Drill":
			player.activeHand = mouse_button
			player.drilling(mouse_button)
		_:
			print("No action configured for weapon type:", weaponType)
			
func getNewPartyMember():
	recruitmentManager.newPartyMember()

#"Sword1": {"type": "Sword", "id": 1, "price": 0, "bought": true}
func updateWeaponPrices():
	for button in weaponStoreMenu.get_children():
		if button.is_in_group("Weapons"):
			var weapon_info = weapon_data.get(button.name)
			if weapon_info:
				var label = button.get_node("Cost")
				label.text = str(weapon_info["price"])
			# IF WE HAVE THE WEAPON, HIDE THE COST
				if weapon_info["bought"] == true:
					label.visible = false
			
func updateRecruitmentPrices():
	for button in hireStoreMenu.get_children():
		if button.is_in_group("recruit"):
			var hireButton = button
			if(hireButton):
				var label = hireButton.get_node("Cost")
				label.text = str(recruitmentManager.partyMemberCost)

func getButtonColors():
	hover_colors = {
		"WeaponStoreButton": Color(0.8, 0, 0),
		"HireStoreButton": Color(0.8, 0.8, 0),
		"LotteryStoreButton": Color(0, 0.8, 0),
		"RecruitButton": recruitButtonColorHover
	}

	pressed_colors = {
		"WeaponStoreButton": Color(0.5, 0, 0),
		"HireStoreButton": Color(0.5, 0.5, 0),
		"LotteryStoreButton": Color(0, 0.5, 0),
		"RecruitButton": recruitButtonColorPressed
	}

func updateUnlockedButton():
	for button in mainStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			if button.is_in_group("unlocked"):
				_orig_colors[button] = Color.WHITE
				hover_colors.erase(button.name)
				pressed_colors.erase(button.name)

