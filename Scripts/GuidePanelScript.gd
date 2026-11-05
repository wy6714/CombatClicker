extends Control

@onready var guideSlideAnim = $GuideSlide
@onready var currentButton
@onready var currentExplanations

@onready var attacking = $TutorialPanelItems/Attacking/AttackingButton
@onready var stats = $TutorialPanelItems/Stats/StatsButton
@onready var ultimateUltRush = $TutorialPanelItems/Ultimate_UltRush/UltimateUltRushButton
@onready var breakEnemies = $TutorialPanelItems/BreakEnemies/BreakEnemiesButton
@onready var levellingUp = $TutorialPanelItems/LevellingUp/LevellingUpButton
@onready var partyMembers = $TutorialPanelItems/PartyMembers/PartyMembersButton
@onready var elements = $TutorialPanelItems/Elements/ElementsButton
@onready var enemyCapturing = $TutorialPanelItems/EnemyCapturing/EnemyCapturingButton
@onready var radiantEnemies = $TutorialPanelItems/RadiantEnemies/RadiantEnemiesButton

@onready var selectSE = $Select
# Called when the node enters the scene tree for the first time.
func _ready():
	
	attacking.pressed.connect(manageGuideButton.bind(attacking))
	stats.pressed.connect(manageGuideButton.bind(stats))
	ultimateUltRush.pressed.connect(manageGuideButton.bind(ultimateUltRush))
	breakEnemies.pressed.connect(manageGuideButton.bind(breakEnemies))
	levellingUp.pressed.connect(manageGuideButton.bind(levellingUp))
	partyMembers.pressed.connect(manageGuideButton.bind(partyMembers))
	elements.pressed.connect(manageGuideButton.bind(elements))
	enemyCapturing.pressed.connect(manageGuideButton.bind(enemyCapturing))
	radiantEnemies.pressed.connect(manageGuideButton.bind(radiantEnemies))
	
	# Attacking is default guide
	currentButton = attacking
	currentButton.button_pressed = true
	currentExplanations = currentButton.get_node("../ExplanationItems")
	currentExplanations.visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func guideSlideIn():
	guideSlideAnim.play("GuideSlideIn")

func guideSlideOut():
	guideSlideAnim.play("GuideSlideOut")

func manageGuideButton(button):
	# on button press, button get node named ExplanationItems, set it visible
	
	# Clear it at the start
	disableGuideButton()
	
	# Set up new button
	currentButton = button
	currentExplanations = currentButton.get_node("../ExplanationItems")
	currentExplanations.visible = true
	
	selectSE.play()
	
func disableGuideButton():
	if(currentExplanations != null):
		currentExplanations.visible = false
		
	if(currentButton):
		currentButton.button_pressed = false
		currentButton = null
