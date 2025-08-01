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

var original_position: Vector2
var tween: Tween
var hovering := false
@onready var poly = $CharUI2/Area2D/CollisionPolygon2D

var hoverBlocked: bool = false

@onready var charUI1 = $CharUI
@onready var charUI2 = $CharUI2

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var world_pos = get_global_mouse_position()
	var local_pos = poly.to_local(world_pos)
	var inside = Geometry2D.is_point_in_polygon(local_pos, poly.polygon)

	if inside and not hovering:
		hovering = true
		onHoverEnter() # Wont trigger if something is blocking the hover
	elif not inside and hovering:
		hovering = false
		onHoverExit() # Wont trigger if something is blocking the hover

		
func gainUpgradePoints():
	upgradePoints += 1
	
func _on_stats_button_button_down():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	var clicked = self  # the member whose button you just hit
	
	# Gray out everyone except the selected one
	for member in get_tree().get_nodes_in_group("UIMember"):
		if member != clicked:
			member.charUI1.modulate = Color.DARK_GRAY
			member.charUI2.modulate = Color.DARK_GRAY

	# CASE A: the menu is closed, open it
	if not statDisplay.open:
		statDisplay.visible = true
		statDisplay.statOpen()  # play opening animation
		_applyMemberToDisplay(statDisplay, clicked)
		statDisplay.open = true
		$CharUI.modulate = Color.WHITE # Make them show as white
		$CharUI2.modulate = Color.WHITE
		return
		
	# CASE B: the menu is open on the same member → close it
	if statDisplay.currentlyDisplayingMember == clicked:
		statDisplay.statClose()  # play closing animation
		statDisplay.open = false
		
		# Return to white
		for member in get_tree().get_nodes_in_group("UIMember"):
			member.charUI1.modulate = Color.WHITE
			member.charUI2.modulate = Color.WHITE
			
		return
	
	# CASE C: the menu is open but on a DIFFERENT member → just swap data
	var previousUI1 = statDisplay.currentlyDisplayingMember.charUI1
	if previousUI1:
		previousUI1.modulate = Color.DARK_GRAY
		
	var previousUI2 = statDisplay.currentlyDisplayingMember.charUI2
	if previousUI2:
		previousUI2.modulate = Color.DARK_GRAY
		
	# bring the new one forward
	$CharUI.modulate = Color.WHITE # it SHOULD make the newly selected party member show as white, but it doesnt...
	$CharUI2.modulate = Color.WHITE
	
	# no change to statDisplay.open, no anim
	_applyMemberToDisplay(statDisplay, clicked)
	statDisplay.randomizePitch($MenuOpen)	
	

func _applyMemberToDisplay(statDisplay, member):
	statDisplay.updateAllPlayerValues(member)  
	statDisplay.member = member
	statDisplay.currentlyDisplayingMember = member
	statDisplay.upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
	statDisplay.upgradePointCostText.text = str(member.upgradePointCost) + " points"
	statDisplay.updateMemberTextColors()
	statDisplay.nameText.text = member.characterName


func _on_line_edit_text_changed(new_text):
	characterName = new_text

func onHoverEnter():
	if(!hoverBlocked):
		if tween: tween.kill() # cancel old tween if it's still running
		tween = create_tween()
		var target_pos = original_position + Vector2(5, -5)
		tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		$MenuHover.play()
	
func onHoverExit():
	if(!hoverBlocked):
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

