extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")

@export var strengthCost = 50;
@export var critRateCost = 100;
@export var critDamageCost = 100;
@export var energyRegenCost = 100;

@onready var swordHolder = get_node("/root/Main/shop/Sword")
@onready var claymoreHolder =  get_node("/root/Main/shop/Claymore")
@onready var drillHolder =  get_node("/root/Main/shop/Drill")


var equippedWeapons = {
	"left": null,
	"right": null
}

var weapons_data = {
	"Sword1": {"cost": 0, "bought": true},
	"Sword2": {"cost": 100, "bought": false},
	"Sword3": {"cost": 100, "bought": false},
	"Claymore1": {"cost": 100, "bought": false},
	"Claymore2": {"cost": 100, "bought": false},
	"Claymore3": {"cost": 100, "bought": false},
	"Drill1": {"cost": 100, "bought": false},
	"Drill2": {"cost": 100, "bought": false},
	"Drill3": {"cost": 100, "bought": false},
}

# Variables to track currently equipped weapon buttons
var equipped_left_click = null
var equipped_right_click = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_sword_button_down():
	toggle_visibility(swordHolder)

func _on_sword_1_button_down():
	# Retrieve all nodes in the "Weapons" group
	# WE DONT BUY THIS ONE, WE HAVE THIS ONE BY DEFAULT
	var weapons = get_tree().get_nodes_in_group("Weapons")
	# Try to find Sword1
	var sword1 = null
	for node in weapons:
		if node.name == "Sword1":
			sword1 = node
			break  # Exit the loop once Sword1 is found
			
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			equip_weapon(sword1, "left")
			print("LEFT")
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			equip_weapon(sword1, "right")
			print("RIGHT")

func _on_sword_2_button_down():
	var weapon_name = "Sword2"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var sword = null
	for node in weapons:
		if node.name == weapon_name:
			sword = node
			break
	
	if sword:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(sword, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(sword, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func _on_sword_3_button_down():
	var weapon_name = "Sword3"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var sword = null
	for node in weapons:
		if node.name == weapon_name:
			sword = node
			break
	
	if sword:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(sword, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(sword, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")
			
func _on_claymore_button_down():
	toggle_visibility(claymoreHolder)
	
func _on_claymore_1_button_down():
	var weapon_name = "Claymore1"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var claymore = null
	for node in weapons:
		if node.name == weapon_name:
			claymore = node
			break
	
	if claymore:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(claymore, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(claymore, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")
	
func _on_claymore_2_button_down():
	var weapon_name = "Claymore2"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var claymore = null
	for node in weapons:
		if node.name == weapon_name:
			claymore = node
			break
	
	if claymore:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(claymore, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(claymore, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func _on_claymore_3_button_down():
	var weapon_name = "Claymore3"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var claymore = null
	for node in weapons:
		if node.name == weapon_name:
			claymore = node
			break
	
	if claymore:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(claymore, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(claymore, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func _on_drill_button_down():
	toggle_visibility(drillHolder)
	
func _on_drill_1_button_down():
	var weapon_name = "Drill1"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var drill = null
	for node in weapons:
		if node.name == weapon_name:
			drill = node
			break
	
	if drill:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(drill, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(drill, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func _on_drill_2_button_down():
	var weapon_name = "Drill2"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var drill = null
	for node in weapons:
		if node.name == weapon_name:
			drill = node
			break
	
	if drill:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(drill, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(drill, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func _on_drill_3_button_down():
	var weapon_name = "Drill3"
	# Check if the weapon is already bought
	if !weapons_data[weapon_name]["bought"]:
		var cost = weapons_data[weapon_name]["cost"]
		if player.score >= cost:
			weapons_data[weapon_name]["bought"] = true
			player.score -= cost
			print(weapon_name + " bought!")
		else:
			print("Not enough score to buy " + weapon_name)
			return
	
	# If already bought, equip the weapon
	var weapons = get_tree().get_nodes_in_group("Weapons")
	var drill = null
	for node in weapons:
		if node.name == weapon_name:
			drill = node
			break
	
	if drill:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			equip_weapon(drill, "left")
			print("Equipped " + weapon_name + " on LEFT hand")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			equip_weapon(drill, "right")
			print("Equipped " + weapon_name + " on RIGHT hand")

func toggle_visibility(weapon_node: Node):
	for child in weapon_node.get_children():
		if child.is_visible():
			child.hide()
		else:
			child.show()

# Function to handle equipping
func equip_weapon(weapon_button: Button, mouse_button: String):
	# Get the Left and Right equip symbols
	var left_symbol = weapon_button.get_node("LeftEquipSymbol")
	var right_symbol = weapon_button.get_node("RightEquipSymbol")

	# Unequip the previously equipped weapon for this mouse button
	if equippedWeapons[mouse_button]:
		var previous_button = equippedWeapons[mouse_button]
		var previous_symbol = previous_button.get_node(
			"LeftEquipSymbol" if mouse_button == "left" else "RightEquipSymbol"
		)
		previous_symbol.hide()

	# Equip the new weapon
	equippedWeapons[mouse_button] = weapon_button
	if mouse_button == "left":
		left_symbol.show()
		right_symbol.hide()
		if(equippedWeapons["right"] == equippedWeapons["left"]):
			equippedWeapons["right"] = null
	elif mouse_button == "right":
		right_symbol.show()
		left_symbol.hide()
		if(equippedWeapons["left"] == equippedWeapons["right"]):
			equippedWeapons["left"] = null

func getWeaponType(weapon_button: Button) -> String:
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
			player.dealDamage()  # Sword's action for any button
		"Claymore":
			player.determineClaymoreButton(mouse_button)
		"Drill":
			player.drilling(mouse_button)
		_:
			print("No action configured for weapon type:", weaponType)
