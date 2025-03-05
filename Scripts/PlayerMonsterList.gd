extends Node2D

# Called when the node enters the scene tree for the first time.
var capturedMonsters = {}

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var playerCapturePanel = $Control
@onready var captureList = $Control/GridContainer

# VARIABLES FOR HOLDING CHANGED STATS
@onready var ogStrength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func captureMonster(monsterName: String, passiveEffect: String):
	if(monsterName in capturedMonsters):
		
		# THIS CODE ENSURES THAT RECEIVING PASSIVE UPGRADES WITH YOUR CURRENTLY SELECTED MONSTER GOES SMNOOTHLY
		var monster = capturedMonsters[monsterName]
		if monster["passiveActive"]:
			resetUnequip(monsterName)
		# USE THE OLD COUNT TO REMOVE THE PASSIVE EFFECT, NOT THE NEW ONE...
			
		monster["count"] += 1
		
		# (RE EQUIP EQUIPPED/NEWLY CAPTURED MOSNTER)
		if monster["passiveActive"]:
			resetEquip(monsterName)
		
	else:
		capturedMonsters[monsterName] = {
			"count": 1,
			"passiveActive": false,
			"effect": passiveEffect,
			"applyEffect": get_passive_function(passiveEffect), # Store function reference
			"removeEffect": get_passive_remove_function(passiveEffect) # Store removal function
		}
	print("Captured: ", monsterName, " | Total: ", capturedMonsters[monsterName]["count"])

# ----------------------------------------------------------------------------------------------------------
func equip_monster(monsterName: String):
	# Unequip any currently active monster
	for name in capturedMonsters.keys():
		if capturedMonsters[name]["passiveActive"]:
			unequip_monster(name)  # Call the unequip function on active monsters
			
	if monsterName in capturedMonsters:
		var monster = capturedMonsters[monsterName]
		if not monster["passiveActive"]:
			monster["passiveActive"] = true
			monster["applyEffect"].call(monsterName)
			print(monsterName, " equipped! Passive activated:", monster["effect"], "Monster Count: ", monster["count"])
			print("EQUIIIIIIIIIIIIIIIIIIIIIIIIIPPPPPPPPPPPPPPED")
	else:
		print("You don't have this monster")
		
func unequip_monster(monsterName: String):
	if monsterName in capturedMonsters:
		var monster = capturedMonsters[monsterName]
		if monster["passiveActive"]:
			monster["passiveActive"] = false
			monster["removeEffect"].call(monsterName)
			print(monsterName, " unequipped! Passive deactivated. aaaaaaaaaaaaaaaaaaaaaaaaa")
	else:
		print("You don't have this monster")

func resetUnequip(monsterName: String):
	if monsterName in capturedMonsters:
		var monster = capturedMonsters[monsterName]
		if monster["passiveActive"]:
			monster["removeEffect"].call(monsterName)
			print(monsterName, " reset hopefully! Passive reset. i hope")
	else:
		print("You don't have this monster")
		
func resetEquip(monsterName: String):
	if monsterName in capturedMonsters:
		var monster = capturedMonsters[monsterName]
		monster["applyEffect"].call(monsterName)
		print(monsterName, " equipped! Passive activated:", monster["effect"], "Monster Count: ", monster["count"])
		print("EQUIIIIIIIIIIIIIIIIIIIIIIIIIPPPPPPPPPPPPPPED")
	else:
		print("You don't have this monster")
#---------------------------------------------------------------------------------------------------------------

#CHICKADEE ENEMY PASSIVE (just a temporary debug strength boost...)
func boostAttack(monsterName: String):
	var strengthBoost = 10
	var boostAmount = strengthBoost * capturedMonsters[monsterName]["count"]
	
	player.strength += boostAmount
	print("Boosted attack! New strength: ", player.strength)
	
	
func removeBoostAttack(monsterName: String):
	var strengthBoost = 10
	var boostAmount = strengthBoost * capturedMonsters[monsterName]["count"]

	# Remove only this monster's boost, without relying on ogStrength
	player.strength -= boostAmount
	print("Attack returned to normal. New Strength:", player.strength)
	
# -------------------------------------------
# Function Mapping (Matches passives to functions)
# -------------------------------------------

func get_passive_function(passiveEffect: String) -> Callable:
	match passiveEffect:
		"Chickadee": return Callable(self, "boostAttack")
		"Chicken": return Callable(self, "boostAttack")
		"Slime": return Callable(self, "boostAttack")
		"Ghost": return Callable(self, "boostAttack")
		"Mushroom": return Callable(self, "boostAttack")
		_:
			return Callable() # Returns an empty callable if no match

func get_passive_remove_function(passiveEffect: String) -> Callable:
	match passiveEffect:
		"Chickadee": return Callable(self, "removeBoostAttack")
		"Chicken": return Callable(self, "removeBoostAttack")
		"Slime": return Callable(self, "removeBoostAttack")
		"Ghost": return Callable(self, "removeBoostAttack")
		"Mushroom": return Callable(self, "removeBoostAttack")
		_:
			return Callable()

# -------------------------------------------------------------------------

func _on_texture_button_button_up():
	playerCapturePanel.visible = false
