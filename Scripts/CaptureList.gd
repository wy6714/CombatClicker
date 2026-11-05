extends GridContainer

@onready var base_button = $TextureButton
@onready var grid = $"."
@onready var monsterSprite = $TextureButton/Sprite2D
var total_monsters = 50

@onready var base_button_scene = preload("res://Scenes/GridMonsterButton.tscn")

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

var radiantUnlocked
var regularUnlocked

var currentRadiantUnlocked = false
var currentRegularUnlocked = false

var radiant
@onready var radiantToggle = $"../../CaptureInfoPanelItems/RadiantToggle"
var isShowingRadiant = false   # tracks current display state

var currentGridSprite: Sprite2D
var currentSingleSprite: Texture2D
var currentRadiantSingleSprite: Texture2D
@onready var selectSE = $"../../../SelectSE"

var monster_list = [
	{"name": "Chickadee", "unlocked": false, "sprite": preload("res://Art/EnemyDesigns/ChickadeeSingle.png"), "radiantSprite": preload("res://Art/EnemyDesigns/RadiantChickadeeSingle.png"), "scene": preload("res://Scenes/EnemyScenes/chickadee.tscn"), 
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
	{"name": "Chicken", "unlocked": false, "sprite": preload("res://Art/EnemyDesigns/ChickenSingle.png"), "radiantSprite": preload("res://Art/EnemyDesigns/RadiantChickenSpritesSingle.png"), "scene": preload("res://Scenes/EnemyScenes/chicken.tscn"), 
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
	{"name": "Slime", "unlocked": false, "sprite": preload("res://Art/EnemyDesigns/SlimeSingle.png"), "radiantSprite": preload("res://Art/EnemyDesigns/RadiantSlimeSingle.png"), "scene": preload("res://Scenes/EnemyScenes/slime.tscn"),
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
	{"name": "Ghost", "unlocked": false, "sprite": preload("res://Art/EnemyDesigns/GhostSingle.png"), "radiantSprite": preload("res://Art/EnemyDesigns/RadiantSpoopyGhostSingle.png"), "scene": preload("res://Scenes/EnemyScenes/ghost.tscn"),
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
	{"name": "Mushroom", "unlocked": false, "sprite": preload("res://Art/EnemyDesigns/MushroomSingle.png"), "radiantSprite": preload("res://Art/EnemyDesigns/RadiantWiggleMushroomSingle.png"), "scene": preload("res://Scenes/EnemyScenes/mushroom.tscn"), 
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
	player_monster_list.monster_captured.connect(_on_monster_captured)

func populate_monster_list() -> void:
	# 1) Clear out existing buttons immediately, not at end of frame
	for button in grid.get_children():
		grid.remove_child(button)
		button.free()
		
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
					
				cnt = player_monster_list.capturedMonsters[monster["name"]]["count"]
				sprite.texture = monster["sprite"]
				
				var is_radiant_unlocked: bool = player_monster_list.capturedMonsters[monster["name"]].get("radiantUnlocked", false)
				var is_regular_unlocked: bool = player_monster_list.capturedMonsters[monster["name"]].get("regularUnlocked", false)
				
				# Show shiny thumbnail only if they own a shiny but NOT the regular version
				if is_radiant_unlocked and not is_regular_unlocked:
					sprite.texture = monster["radiantSprite"]
				else:
					sprite.texture = monster["sprite"]
		
				btn.pressed.connect(
					Callable(self, "_on_texture_button_button_down")
						.bind(
							monster,
							monster["sprite"],
							cnt,
							monster["scene"],
							monster["lore"],
							monster["pats"],
							is_radiant_unlocked,
							is_regular_unlocked,
							sprite
						)
				)
			else:
				# Defined monster, but not caught yet.
				sprite.texture = preload("res://Art/QuestionMark.png")
				btn.pressed.connect(_show_unknown_monster)

		else:
			# --- placeholder slot beyond your defined monsters ---
			sprite.texture = preload("res://Art/QuestionMark.png")
			btn.pressed.connect(_show_unknown_monster)

		grid.add_child(btn)

	print("populated")


func _show_unknown_monster() -> void:
	# Clear the previously selected monster.
	currentMonster = null
	currentGridSprite = null

	# Disable radiant display options.
	currentRadiantUnlocked = false
	currentRegularUnlocked = false
	radiantToggle.visible = false
	radiantToggle.disabled = true

	# Display unknown monster information.
	nametag.text = "???"
	pats_label.text = "???"

	# Play the question mark animation.
	monsterAnimatedSprite.sprite_frames = question_mark_frames
	monsterAnimatedSprite.animation = "default"
	monsterAnimatedSprite.play()

	# Lock all lore entries.
	for trivia in get_tree().get_nodes_in_group("Trivia"):
		trivia.text = "???"

	# Disable interaction with the monster display.
	monsterArea.input_pickable = false
	
func _on_monster_captured(monster_name: String):
	if $"../../..".visible == false:
		return
		
	populate_monster_list()
		
	if currentMonster != null and currentMonster.get("name", "") == monster_name:
		var captured_data = player_monster_list.capturedMonsters[monster_name]
		var monster_index = monster_list.find(currentMonster)
		if monster_index != -1:
			var monster = monster_list[monster_index]
			
			# Grab the freshly-rebuilt button/sprite at this index, since the old node was freed
			var new_grid_sprite: Sprite2D = null
			if monster_index < grid.get_child_count():
				var new_btn = grid.get_child(monster_index)
				new_grid_sprite = new_btn.get_node("Sprite2D")
			
			on_monster_selected(
				monster_name,
				monster["sprite"],
				captured_data["count"],
				monster["scene"],
				monster["lore"],
				currentMonster["pats"],
				captured_data.get("radiantUnlocked", false),
				captured_data.get("regularUnlocked", false),
				new_grid_sprite
			)		
		
func on_monster_selected(monster_name: String, sprite_tex: Texture2D, count: int, monster_scene: PackedScene, lore_list: Array, pats: int, radiantUnlocked: bool, regularUnlocked: bool, gridSprite: Sprite2D):
	print("Monster Selected : ", monster_name)
	
	nametag.text = monster_name
	getTrivia(count, lore_list)
	pats_label.text = str(currentMonster["pats"])
	monsterArea.input_pickable = true
	
	currentRadiantUnlocked = radiantUnlocked
	currentRegularUnlocked = regularUnlocked
	
	currentGridSprite = gridSprite
	currentSingleSprite = currentMonster["sprite"]
	currentRadiantSingleSprite = currentMonster["radiantSprite"]
	
	# Toggle visibility: only show it at all if they own a shiny
	radiantToggle.visible = radiantUnlocked
	
	# Decide the default display: shiny-only-owned forces shiny, otherwise default to regular
	var showRadiantByDefault = radiantUnlocked and not regularUnlocked
	
	if radiantUnlocked:
		if regularUnlocked:
			# They own both — toggle is free to flip either way
			radiantToggle.disabled = false
		else:
			# Only shiny owned — lock the toggle "on", can't switch to regular
			radiantToggle.disabled = true
	
	# — now for the animated sprite —
	var enemy_instance = monster_scene.instantiate()
	var enemy_area = enemy_instance.get_node("Area2D")
	var original_anim: AnimatedSprite2D = enemy_area.get_node("AnimatedSprite2D")
	var original_collider: CollisionShape2D = enemy_area.get_node("CollisionShape2D")
	
	monsterAnimatedSprite.sprite_frames = original_anim.sprite_frames.duplicate()
	setDisplayRadiant(showRadiantByDefault)   # <-- replaces the old animation-copy line

	monsterCollider.shape = original_collider.shape.duplicate()
	monsterCollider.scale = original_collider.scale * 4
	monsterCollider.position = original_collider.position

	match_collider_to_sprite()
	enemy_instance.queue_free()
	
func setDisplayRadiant(showRadiant: bool) -> void:
	radiant = showRadiant
	var currentFrame = monsterAnimatedSprite.frame
	monsterAnimatedSprite.animation = "RIdle" if showRadiant else "Idle"
	monsterAnimatedSprite.frame = currentFrame
	monsterAnimatedSprite.play()
	
	if currentGridSprite:
		currentGridSprite.texture = currentRadiantSingleSprite if showRadiant else currentSingleSprite
	
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
			if(!radiant):
				monsterAnimatedSprite.animation = "Happy" # Happy anim name
			else:
				monsterAnimatedSprite.animation = "RHappy"
			
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
	if(!radiant):
		monsterAnimatedSprite.animation = "Idle"
	else:
		monsterAnimatedSprite.animation = "RIdle"
		
	monsterAnimatedSprite.frame = currentFrame
	monsterAnimatedSprite.play()
	currentlyPatting = false
		

func _on_texture_button_button_down(
	monster: Dictionary,
	tex: Texture2D,
	cnt: int,
	scene: PackedScene,
	lore: Array,
	patTotal: int,
	radiantUnlocked: bool,
	regularUnlocked: bool,
	gridSprite: Sprite2D
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
		patTotal,
		radiantUnlocked,
		regularUnlocked,
		gridSprite
	)

func _on_radiant_toggle_button_down() -> void:
	if not currentRadiantUnlocked:
		return
	if not currentRegularUnlocked:
		return  # only shiny owned — nothing to toggle to, ignore the press
	
	isShowingRadiant = not isShowingRadiant
	setDisplayRadiant(isShowingRadiant)
	selectSE.play()
	
