extends Control

@onready var playerCapturePanel = get_node("/root/Main/Player/PlayerMonsterList/Control/") # Get a reference to the player

@onready var player_monster_list = get_node("/root/Main/Player/PlayerMonsterList/Control/GridContainer")

func _on_texture_button_button_down():
	playerCapturePanel.visible = true
	player_monster_list.populate_monster_list()

func newCaptureBounce():
	$NewCaptureAnim.play("newCaptureLabelBounce")
