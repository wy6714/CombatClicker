extends Node2D

# STATS
@export var characterName: String = "You"
@export var strength: float = 5
@export var critRate: float = 33
@export var critDamage: float = 2
@export var ultRegen: float = 1
@export var crit: bool = false # Tracking IF we crit
@export var damage: float = 0
@export var cooldown: float = 7
@export var statusRate: float = 1
@export var ultPotency: float = 0
var currentElement = ""

@export var bonusStrength: float = 0
@export var bonusCritRate: float = 0
@export var bonusCritDamage: float = 0
@export var bonusUltRegen: float = 0
@export var bonusCooldown: float = 0
@export var bonusStatusRate: float = 0
@export var bonusUltPotency: float = 0

@export var baseStrength: float = 5
@export var baseCritRate: float = 5 
@export var baseCritDamage: float = 2
@export var baseUltRegen: float = 1
@export var baseCooldown: float = 7
@export var baseStatusRate: float = 1
@export var baseUltPotency: float = 0

@export var upgradePoints: int = 0
@export var upgradeCostMultiplier: float = 1.0
@export var totalAccumulatedUpgradePoints: int = 0
@export var upgradePointCost: int = 1000

# REFERENCES
@onready var player = get_node("/root/Main/Player")
@onready var ultBarSystem = get_node("/root/Main/UltMeter")
@onready var damageCooldown = $CharUI/DamageCooldown

@onready var nameLine = $CharUI/LineEdit
@onready var statsButton = $CharUI2/StatsButton

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
@onready var upgradePointFeedbackLocation = $"+1 Upgrade Point Loc"

@export var fire = false
@export var water = false
@export var wind = false
@export var earth = false
@export var electric = false

@onready var shopUI = get_node("/root/Main/ShopUI")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Buffable")
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

func _handle_stats_button_click():
	var statDisplay = get_node("/root/Main/PartyMemberStatHolderUI")
	var clicked = self
	
	for member in get_tree().get_nodes_in_group("UIMember"):
		member.nameLine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		member.statsButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Gray out everyone except the selected one
	for member in get_tree().get_nodes_in_group("UIMember"):
		if member != clicked:
			member.charUI1.modulate = Color.DARK_GRAY
			member.charUI2.modulate = Color.DARK_GRAY
			

	# CASE A: the menu is closed, open it
	if not statDisplay.open:
		statDisplay.visible = true
		statDisplay.statOpen()
		_applyMemberToDisplay(statDisplay, clicked)
		statDisplay.open = true
		$CharUI.modulate = Color.WHITE
		$CharUI2.modulate = Color.WHITE
		return
		
	# CASE B: the menu is open on the same member → close it
	if statDisplay.currentlyDisplayingMember == clicked:
		statDisplay.statClose()
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
		
	$CharUI.modulate = Color.WHITE
	$CharUI2.modulate = Color.WHITE
	_applyMemberToDisplay(statDisplay, clicked)
	statDisplay.randomizePitch($MenuOpen)

func gainUpgradePoints():
	upgradePoints += 1

	
func _on_stats_button_button_down():
	_handle_stats_button_click()

func _applyMemberToDisplay(statDisplay, member):
	statDisplay.updateAllPlayerValues(member)  
	statDisplay.member = member
	statDisplay.currentlyDisplayingMember = member
	statDisplay.upgradePointText.text = "Upgrade Points " + str(member.upgradePoints)
	statDisplay.upgradePointCostText.text = str(member.upgradePointCost) + " points"
	statDisplay.updateMemberTextColors()
	statDisplay.nameText.text = member.getDisplayName()

func _on_line_edit_text_changed(new_text):
	characterName = new_text

	var line_edit = $CharUI/LineEdit
	var font = line_edit.get_theme_font("font")

	var font_size = 24
	var minimum_size = 10
	var available_width = line_edit.size.x - 10

	while font_size > minimum_size:
		var text_width = font.get_string_size(
			new_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size
		).x

		if text_width <= available_width:
			break

		font_size -= 1

	line_edit.add_theme_font_size_override("font_size", font_size)

	# Prevent the LineEdit from scrolling to the cursor
	# after the font size changes.
	var old_caret = line_edit.caret_column
	line_edit.caret_column = 0
	line_edit.caret_column = old_caret

	if shopUI:
		shopUI.updatePlayerName(getDisplayName())

func onHoverEnter():
	if(!hoverBlocked):
		if tween: tween.kill() # cancel old tween if it's still running
		tween = create_tween()
		var target_pos = original_position + Vector2(2, -5)
		tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		$MenuHover.play()
	
func onHoverExit():
	if(!hoverBlocked):
		if tween: tween.kill()
		tween = create_tween()
		tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			nameLine.release_focus()

func getDisplayName() -> String:
	if characterName.strip_edges().is_empty():
		return "You"
	
	return characterName
