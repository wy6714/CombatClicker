extends GridContainer

@onready var base_button = $TextureButton
@onready var grid = $"."
@onready var monsterSprite = $TextureButton/Sprite2D
var total_monsters = 50

@onready var base_button_scene = preload("res://Scenes/GridMonsterButton.tscn")
@onready var currentButtonSprite = get_node("/root/Main/CurrentMonsterIconButton/TextureButton/MonsterIcon")

@onready var nametag = $"../../CaptureInfoPanelItems/Name"
@onready var pats_label = $"../../CaptureInfoPanelItems/PetLabel"
@onready var monsterAnimatedSprite = $"../../CaptureInfoPanelItems/Area2D/Monster Animated Sprite"
@onready var monsterCollider = $"../../CaptureInfoPanelItems/Area2D/CollisionShape2D"
@onready var currentMonster
@onready var monsterArea = $"../../CaptureInfoPanelItems/Area2D"
@onready var question_mark_frames: SpriteFrames = preload("res://Art/questionMarkFloat.tres")
@onready var petParticles = preload("res://Scenes/pet_particles.tscn")
@onready var happyTimer = $"../../HappyTimer"
@onready var currentlyPatting = false
@onready var mouseInsideRadius = false
var queued_anim: String = ""


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

					# 2) ? Animation
					monsterAnimatedSprite.sprite_frames = question_mark_frames
					monsterAnimatedSprite.animation = "default"  # or whatever the anim is called
					monsterAnimatedSprite.play()

					# 3) Show 0 pats
					pats_label.text = "???"
					
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
	# 1) Instance the enemy scene so we can read its AnimatedSprite2D and collider
	var enemy_instance = monster_scene.instantiate()
	var enemy_area = enemy_instance.get_node("Area2D")
	var original_anim: AnimatedSprite2D = enemy_area.get_node("AnimatedSprite2D")
	var original_collider: CollisionShape2D = enemy_area.get_node("CollisionShape2D")

	# 4) Set the animated sprite
	monsterAnimatedSprite.sprite_frames = original_anim.sprite_frames.duplicate()
	monsterAnimatedSprite.animation = original_anim.animation
	monsterAnimatedSprite.play()

	# 5) Set the collider shape and scale to match the enemy
	monsterCollider.shape = original_collider.shape.duplicate()
	monsterCollider.scale = original_collider.scale * 4
	monsterCollider.position = original_collider.position

	# 6) (Optional) If collider looks wrong, use fallback based on sprite size:
	match_collider_to_sprite()

	# Lastly, tidy up the temporary instance
	enemy_instance.queue_free()

func match_collider_to_sprite():
	var tex = monsterAnimatedSprite.sprite_frames.get_frame_texture(monsterAnimatedSprite.animation, 0)
	if tex:
		var size = tex.get_size()
		var shape = RectangleShape2D.new()
		shape.extents = size / 2
		monsterCollider.shape = shape
		monsterCollider.position = Vector2.ZERO
		
		

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
		if(currentMonster != null):
			currentMonster["pats"] += 1
			pats_label.text = str(currentMonster["pats"])
			
				# 1) Create a fresh heart particle
			var heart = petParticles.instantiate()
			add_child(heart)                       # add into the scene tree
			heart.global_position = event.position
			heart.emitting = true                  # fire it
			
			# 2) Switch anim
			var currentFrame = monsterAnimatedSprite.frame # Get the frame
			monsterAnimatedSprite.animation = "Happy" # Happy anim name
			
			if(!currentlyPatting): # Only apply the current frame to the new animation ONCE (otherwise there is pausing)
				monsterAnimatedSprite.frame = currentFrame
			
			monsterAnimatedSprite.play() # Play
			currentlyPatting = true # Track patting
			happyTimer.start(2.0) # Rewset timer

			# 3) Auto‐free after its lifetime (will cause delay for anything below it)
			var t = get_tree().create_timer(heart.lifetime)
			await t.timeout
			if heart.is_inside_tree():
				heart.queue_free()
	
func _on_area_2d_mouse_entered():
	mouseInsideRadius = true
	if $"../../../EnemyScale".is_playing():
		queued_anim = "ScaleUp"
	else:
		$"../../../EnemyScale".play("ScaleUp")
		
func _on_area_2d_mouse_exited():
	mouseInsideRadius = false
	if $"../../../EnemyScale".is_playing():
		queued_anim = "ScaleDown"
	else:
		$"../../../EnemyScale".play("ScaleDown")
			
func _on_enemy_scale_animation_finished(anim_name):
	if queued_anim != "":
		var next_anim = queued_anim
		queued_anim = "" # Clear it so it doesn't loop forever
		$"../../../EnemyScale".play(next_anim)

func _on_happy_timer_timeout():
	var currentFrame = monsterAnimatedSprite.frame
	monsterAnimatedSprite.animation = "Idle"
	monsterAnimatedSprite.frame = currentFrame
	monsterAnimatedSprite.play()
	currentlyPatting = false
		

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
	
	# 4) Equip the monster
	
	player_monster_list.equip_monster(monster["name"])
	

	
	

