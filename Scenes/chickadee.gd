extends Node2D

@onready var anim = $Area2D/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Clicked!")

