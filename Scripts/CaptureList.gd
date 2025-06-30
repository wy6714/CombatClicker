extends GridContainer

@onready var base_button = $TextureButton
@onready var grid = $"."
@onready var monsterSprite = $TextureButton/Sprite2D
var total_monsters = 50

@onready var base_button_scene = preload("res://Scenes/GridMonsterButton.tscn")
@onready var currentButtonSprite = get_node("/root/Main/CurrentMonsterIconButton/TextureButton/MonsterIcon")

@onready var nametag = $"../Name"
@onready var pats_label = $"../PetLabel"
@onready var monsterAnimatedSprite = $"../Area2D/Monster Animated Sprite"
@onready var currentMonster
@onready var monsterArea = $"../Area2D"

var monster_list = [
	{"name": "Chickadee", "unlocked": false, "sprite": preload("res://Art/ChickadeeSingle.png"), "scene": preload("res://Scenes/EnemyScenes/chickadee.tscn"), 
	"lore":
		["This is where lore 1 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 2 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 3 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 4 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 5 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 6 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 7 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 8 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 9 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 10 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh."
	], "pats": 0},
	{"name": "Chicken", "unlocked": false, "sprite": preload("res://Art/ChickenSingle.png"), "scene": preload("res://Scenes/EnemyScenes/chicken.tscn"), 
	"lore":
		["This is where lore 1 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 2 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 3 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 4 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 5 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 6 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 7 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 8 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 9 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 10 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh."
	], "pats": 0
		},
	{"name": "Slime", "unlocked": false, "sprite": preload("res://Art/SlimeSingle.png"), "scene": preload("res://Scenes/EnemyScenes/slime.tscn"),
	"lore":
		["This is where lore 1 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 2 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 3 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 4 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 5 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 6 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 7 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 8 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 9 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 10 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh."
	], "pats": 0
		},
	{"name": "Ghost", "unlocked": false, "sprite": preload("res://Art/GhostSingle.png"), "scene": preload("res://Scenes/EnemyScenes/ghost.tscn"),
	"lore":
		["This is where lore 1 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 2 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 3 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 4 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 5 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 6 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 7 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 8 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 9 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 10 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh."
	], "pats": 0
		},
	{"name": "Mushroom", "unlocked": false, "sprite": preload("res://Art/MushroomSingle.png"), "scene": preload("res://Scenes/EnemyScenes/mushroom.tscn"), 
	"lore":
		["This is where lore 1 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 2 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 3 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 4 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 5 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 6 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 7 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 8 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 9 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh.",
	 "This is where lore 10 for this enemy is stored. Blah blah blah yadda yadda yadda humbly dee humbly doo scooby dooby doo. Yuh."
	], "pats": 0
		},
	# Add all 50 monsters here...
]

@onready var player_monster_list = get_node("/root/Main/Player/PlayerMonsterList")

func _ready():
	base_button.queue_free()
	populate_monster_list()

func populate_monster_list() -> void:
	# 1) Clear out existing buttons
	for button in grid.get_children():
		button.queue_free()

	# 2) Build exactly total_monsters slots
	for i in range(total_monsters):
		var btn = base_button_scene.instantiate()
		var sprite = btn.get_node("Sprite2D")
		var cnt := 0

		if i < monster_list.size():
			# --- real monster slot ---
			var monster = monster_list[i]
			if monster["name"] in player_monster_list.capturedMonsters \
					and player_monster_list.capturedMonsters[monster["name"]]["count"] > 0:

				# unlocked
				cnt = player_monster_list.capturedMonsters[monster["name"]]["count"]
				sprite.texture = monster["sprite"]
				

				btn.pressed.connect(
					Callable(self, "_on_texture_button_button_down")
						.bind(
							monster,
							monster["sprite"],
							cnt,
							monster["scene"],
							monster["lore"],
							monster["pats"]
						)
				)
			else:
				# defined monster but locked
				sprite.texture = preload("res://Art/QuestionMark.png")
				btn.pressed.connect(func ():
					# 1) Show "???" for name
					nametag.text = "???"

					# 2) Clear/stop the animated sprite
					#    (either remove its frames or just stop it)
					monsterAnimatedSprite.stop()
					monsterAnimatedSprite.sprite_frames = null

					# 3) Show 0 pats
					pats_label.text = "0"
					
					# 4) Blank out all lore entries
					for trivia in get_tree().get_nodes_in_group("Trivia"):
						trivia.text = "???"
						
					# 5) Disable clicks
					monsterArea.input_pickable = false
	)

		else:
			# --- placeholder slot beyond your defined monsters ---
			sprite.texture = preload("res://Art/QuestionMark.png")
			btn.pressed.connect(
				Callable(self, "_on_texture_button_button_down")
					.bind(
						null,
						preload("res://Art/QuestionMark.png"),
						0,
						null,
						[],
						0
					)
			)

		grid.add_child(btn)

	print("populated")

	
func on_monster_selected(monster_name: String, sprite_tex: Texture2D, count: int, monster_scene: PackedScene, lore_list: Array, pats: int):
	nametag.text = monster_name
	getTrivia(count, lore_list)
	pats_label.text = str(currentMonster["pats"])
	monsterArea.input_pickable = true
	
	currentButtonSprite.texture = sprite_tex   # static image, if you still want it

	# — now for the animated sprite —
	# 1) Instance the enemy scene so we can read its AnimatedSprite2D
	var enemy_instance = monster_scene.instantiate()
	var original_anim : AnimatedSprite2D = enemy_instance.get_node("Area2D/AnimatedSprite2D")

	# 2) Copy over its SpriteFrames resource & animation state
	#    If you want to keep the UI instance totally independent, duplicate the frames:
	monsterAnimatedSprite.sprite_frames = original_anim.sprite_frames.duplicate()

	#    Copy the current (or default) animation name
	monsterAnimatedSprite.animation = original_anim.animation
	monsterAnimatedSprite.play()   # start animating

	# 3) (Optional) Tidy up the temporary instance
	enemy_instance.queue_free()

func updateMonsterPanel(monster_name, sprite_texture):
	pass

func getTrivia(captureSum: int, loreList: Array) -> void:
	var labels = get_tree().get_nodes_in_group("Trivia")
	# If no lore passed or it's not even an array, lock everything
	if typeof(loreList) != TYPE_ARRAY:
		for trivia in labels:
			trivia.text = "--Locked--"
		return

	# Make sure we never index past the end of loreList
	var maxUnlocked = min(captureSum, loreList.size())

	for i in range(labels.size()):
		var trivia = labels[i]
		if i < maxUnlocked:
			trivia.text = loreList[i]
		else:
			trivia.text = "--Locked--"

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: #On left mouse click...
		currentMonster["pats"] += 1
		pats_label.text = str(currentMonster["pats"])
		print(currentMonster["pats"])
		print(currentMonster["name"])


func _on_texture_button_button_down(
	monster: Dictionary,
	tex: Texture2D,
	cnt: int,
	scene: PackedScene,
	lore: Array,
	patTotal: int
) -> void:

	# 1) Capture the selected monster
	currentMonster = monster

	# 2) Figure out the name (because GDScript has no ?: operator)
	var name: String
	if monster:
		name = monster["name"]
	else:
		name = "Unknown"

	# 3) Delegate to your existing handler
	on_monster_selected(
		name,
		tex,
		cnt,
		scene,
		lore,
		patTotal
	)
