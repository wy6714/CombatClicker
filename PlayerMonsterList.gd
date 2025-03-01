extends Node2D

# Called when the node enters the scene tree for the first time.
var capturedMonsters = {}

@onready var player = get_node("/root/Main/Player") # Get a reference to the player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_V):
		equip_monster("Chickadee")  # Replace with selected monster
	
	if Input.is_key_pressed(KEY_B):
		unequip_monster("Chickadee")  # Replace with selected monster
	
func captureMonster(monsterName: String, passiveEffect: String):
	if(monsterName in capturedMonsters):
		capturedMonsters[monsterName]["count"] += 1
	else:
		capturedMonsters[monsterName] = {
			"count": 1,
			"passiveActive": false,
			"effect": passiveEffect,
			"applyEffect": get_passive_function(passiveEffect), # Store function reference
			"removeEffect": get_passive_remove_function(passiveEffect) # Store removal function
		}
	print("Captured: ", monsterName, " | Total: ", capturedMonsters[monsterName]["count"])

func equip_monster(monsterName: String):
	if monsterName in capturedMonsters:
		var monster = capturedMonsters[monsterName]
		if not monster["passiveActive"]:
			monster["passiveActive"] = true
			monster["applyEffect"].call(monsterName)
			print(monsterName, " equipped! Passive activated:", monster["effect"])
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

#CHICKADEE ENEMY PASSIVE (just a temporary debug strength boost...)
func boostAttack(monsterName: String):
	var strengthBoost = 5
	player.strength += strengthBoost * capturedMonsters[monsterName]["count"]
	print("Boosted attack! New strength: ", player.strength)
	
func removeBoostAttack(monsterName: String):
	var strengthBoost = 5
	player.strength -= strengthBoost * capturedMonsters[monsterName]["count"]
	print("Attack returned to normal. New Strength:", player.strength)
	
# -------------------------------------------
# Function Mapping (Matches passives to functions)
# -------------------------------------------

func get_passive_function(passiveEffect: String) -> Callable:
	match passiveEffect:
		"Attack Boost": return Callable(self, "boostAttack")
		"HP Regen": return Callable(self, "regenHealth")
		_:
			return Callable() # Returns an empty callable if no match

func get_passive_remove_function(passiveEffect: String) -> Callable:
	match passiveEffect:
		"Attack Boost": return Callable(self, "removeBoostAttack")
		"HP Regen": return Callable(self, "removeRegenHealth")
		_:
			return Callable()
