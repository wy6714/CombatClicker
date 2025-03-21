extends Control

@onready var player = get_node("/root/Main/Player") # Get a reference to the player
@onready var expBar = $TextureProgressBar
@onready var levelText = $TextureProgressBar/LevelText
# Called when the node enters the scene tree for the first time.
func _ready():
	expBar.value = 0


