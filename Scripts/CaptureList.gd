extends GridContainer

@onready var base_button = $TextureButton
@onready var grid = $"."
@onready var monsterSprite = $TextureButton/Sprite2D

var total_monsters = 50

@onready var base_button_scene = preload("res://Scenes/GridMonsterButton.tscn")

var monster_list = [
	{"name": "Chickadee", "unlocked": false, "sprite": preload("res://Art/ChickadeeSingle.png")},
	{"name": "Chicken", "unlocked": false, "sprite": preload("res://Art/ChickenSingle.png")},
	{"name": "Slime", "unlocked": false, "sprite": preload("res://Art/SlimeSingle.png")},
	{"name": "Ghost", "unlocked": false, "sprite": preload("res://Art/GhostSingle.png")},
	{"name": "Mushroom", "unlocked": false, "sprite": preload("res://Art/MushroomSingle.png")},
	# Add all 50 monsters here...
]

@onready var player_monster_list = get_node("/root/Main/Player/PlayerMonsterList")

func _ready():
	base_button.queue_free()
	populate_monster_list()

func populate_monster_list():
	
	# Clear out existing buttons
	for button in grid.get_children():
		button.queue_free()  # Free any existing buttons in the grid container

	for i in range(total_monsters):
		var button = base_button_scene.instantiate()
		var sprite = button.get_node("Sprite2D")
		
		if i < monster_list.size():
			var monster = monster_list[i]
			# Check if the monster is captured and unlocked
			if monster["name"] in player_monster_list.capturedMonsters and player_monster_list.capturedMonsters[monster["name"]]["count"] > 0:
				sprite.texture = monster["sprite"]
			else:
				sprite.texture = preload("res://Art/QuestionMark.png")  # Use a question mark sprite
			button.pressed.connect(func(): on_monster_selected(monster["name"]))
		else:
			# Empty slot, display a "?" or generic locked sprite
			sprite.texture = preload("res://Art/QuestionMark.png")  # Use a question mark sprite
			button.pressed.connect(func(): on_monster_selected("Unknown"))

		grid.add_child(button)
	print("populated")

func on_monster_selected(monster_name):
	print("Selected:", monster_name)
