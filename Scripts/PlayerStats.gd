extends Node2D

# STATS
@export var characterName: String = "You"
@export var strength: float = 1
@export var critRate: float = 5
@export var critDamage: float = 2
@export var ultRegen: float = 1
@export var crit: bool = false # Tracking IF we crit
@export var damage: float = 0
@export var cooldown: float = 7
@export var statusRate: float = 0
@export var ultPotency: float = 0
var currentElement = ""

@export var bonusStrength: float = 0
@export var bonusCritRate: float = 0
@export var bonusCritDamage: float = 0
@export var bonusUltRegen: float = 0
@export var bonusCooldown: float = 0
@export var bonusStatusRate: float = 0
@export var bonusUltPotency: float = 0

@export var baseStrength: float = 1
@export var baseCritRate: float = 5 
@export var baseCritDamage: float = 2
@export var baseUltRegen: float = 1
@export var baseCooldown: float = 7

@export var upgradePoints: int = 0
@export var upgradeCostMultiplier: float = 1.0
@export var totalAccumulatedUpgradePoints: int = 0
@export var upgradePointCost: int = 1000

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown
@onready var nameLine = $CharUI/LineEdit
var currentEnemy

var open = false
var isPlayer = true

@onready var buffAnim = $BuffLines
@onready var ultFlashAnim = $UltFlash

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

		
func gainUpgradePoints():
	upgradePoints += 1
	
func _on_stats_button_button_down():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	
	if(!open):
		statDisplay.visible = true
		statDisplay.updateAllPlayerValues(self)
		open = true
		
		statDisplay.member = $"."
		statDisplay.upgradePointText.text = "Upgrade Points " + str(statDisplay.member.upgradePoints)
		statDisplay.upgradePointCostText.text = str(upgradePointCost) + " points"
		statDisplay.updateMemberTextColors()
		statDisplay.nameText.text = characterName
		statDisplay.currentlyDisplayingMember = self
	elif(open):
		statDisplay.visible = false
		open = false
		statDisplay.upgradePointCostText.text = str(upgradePointCost) + " points"
		statDisplay.member = null


func _on_line_edit_text_changed(new_text):
	characterName = new_text
