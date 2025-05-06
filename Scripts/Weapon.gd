extends Node2D

# WeaponDatabase.gd
var weapon_stats = {
	"Sword1": {
		"type": "Sword",
		"strength": 50,
		"crit_rate": 1,
		"crit_damage": 1,
		"ult_regen": 1,
		"elements": ["Fire"]
	},
	"Sword2": {
		"type": "Sword",
		"strength": 100,
		"crit_rate": 0.05,
		"crit_damage": 1.3,
		"ult_regen": 0.05,
		"elements": ["Fire"]
	},
	"Sword3": {
		"type": "Sword",
		"strength": 150,
		"crit_rate": 0.05,
		"crit_damage": 1.3,
		"ult_regen": 0.05,
		"elements": ["Fire"]
	},
	"Claymore1": {
		"type": "GreatSword",
		"strength": 200,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Electric"]
	},
	"Claymore2": {
		"type": "GreatSword",
		"strength": 250,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Electric"]
	}
	# ... more weapons here
}
