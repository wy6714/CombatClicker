extends Control

@export var grayBackground: Texture2D
@export var flashRedBackground: Texture2D
@export var whiteBackground: Texture2D

@onready var backgroundTexture = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func flashRed():
	backgroundTexture.texture = flashRedBackground
	$Timer.start()
	
func _on_timer_timeout():
	backgroundTexture.texture = grayBackground
