extends Node2D

# WeaponDatabase.gd
var weapon_stats = {
	"Sword1": {
		"type": "Sword",
		"strength": 999,
		"crit_rate": 1,
		"crit_damage": 1,
		"ult_regen": 499,
		#"elements": ["Fire", "Water", "Wind", "Earth", "Electric"],
		"elements": ["Earth", "Water", "Fire"],
		"status_rate": 5
	},
	"Sword2": {
		"type": "Sword",
		"strength": 100,
		"crit_rate": 0.05,
		"crit_damage": 1.3,
		"ult_regen": 0.05,
		"elements": ["Water"],
		"status_rate": 80
	},
	"Sword3": {
		"type": "Sword",
		"strength": 150,
		"crit_rate": 0.05,
		"crit_damage": 1.3,
		"ult_regen": 0.05,
		"elements": ["Wind"],
		"status_rate": 10
	},
	"Claymore1": {
		"type": "GreatSword",
		"strength": 200,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Fire", "Water", "Wind", "Earth", "Electric"],
		"status_rate": 1
	},
	"Claymore2": {
		"type": "GreatSword",
		"strength": 250,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Fire"],
		"status_rate": 10
	},
	"Claymore3": {
		"type": "GreatSword",
		"strength": 250,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Fire"],
		"status_rate": 10
	},
	"Drill1": {
		"type": "GreatSword",
		"strength": 1,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Fire"],
		"status_rate": 10
	},
	"Drll2": {
		"type": "GreatSword",
		"strength": 250,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Fire"],
		"status_rate": 10
	},
	"Drill3": {
		"type": "GreatSword",
		"strength": 250,
		"crit_rate": 0.1,
		"crit_damage": 2.0,
		"ult_regen": 0.02,
		"elements": ["Earth", "Fire"],
		"status_rate": 10
	}
	# ... more weapons here
}
