extends Control

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var expBar = $ExpBar/ProgressBar
@onready var levelText = $ExpBar/LevelText
# Called when the node enters the scene tree for the first time.
func _ready():
	expBar.value = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

