extends Control

@onready var ultProgressBar = $TextureProgressBar
@onready var ultText = $TextureProgressBar/UltText
@export var currentUltValue: float = 0.0
@export var ultMax: int = 1000
@export var canUlt: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ultProgressBar.value = 0
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(currentUltValue >= ultMax):
		canUlt = true
	else:
		canUlt = false

func updateUltProgress(ultRecharge):
	currentUltValue += ultRecharge
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	
func subtractUltProgress():
	currentUltValue -= ultMax
	ultProgressBar.value = currentUltValue
	ultText.text = str(currentUltValue) + "/ " + str(ultMax)
	
	
