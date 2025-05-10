extends Node

#THIS FUNCTION IS AUTOLOADED. It is not quite attached to anything, all nodes will have access to it
#(HOPEFULLY...)

@onready var dmgFont = preload("res://Fonts/Press_Start_2P/PressStart2P-Regular.ttf")
@onready var damageText = preload("res://Scenes/damage_text.tscn")

func display_number(value: int, position: Vector2, isCrit: bool = false):
	
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	var fontSize = 24
	var critFontSize = 28
	
	var color = "#FFF"
	if isCrit:
		color = "#B22"
		number.label_settings.font_size = critFontSize
	if value == 0:
		color = "#FFF8"
		number.label_settings.font_size = fontSize
	
	number.label_settings.font = dmgFont
	number.label_settings.font_color = color
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
		
func display_big_number(value: int, position: Vector2, isCrit: bool = false):
	var number = Label.new()
	# Place the number at the center position with your desired X offset (-75)
	number.global_position = position + Vector2(-75, 0)
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	
	# Set alignment to center for Godot 4
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Font size settings
	var fontSize = 70
	
	# Set font and styling
	number.label_settings.font = dmgFont
	number.label_settings.outline_size = 8
	number.label_settings.font_size = fontSize
	
	if isCrit:
		number.label_settings.font_color = Color("#FFD700")  # Gold for crits
		number.label_settings.outline_color = Color("#8E1A1A") # Deep red outline
	else:
		number.label_settings.font_color = Color("#8E1A1A")  # Red for normal hits
		number.label_settings.outline_color = Color("#FFF")    # White outline
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = number.size / 2
	
	# Create a tween to float the number upward
	var tween = get_tree().create_tween()
	tween.set_parallel(false)  # Sequential tweening
	
	# Step 1: Float up over 0.6 seconds
	tween.tween_property(
		number, "position:y", number.position.y - 64, 0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Wait until the float-up tween finishes
	await tween.finished
	
	# Step 2: Instantiate and add the extra damage text as a child of the number
	var extraEffect = damageText.instantiate()
	number.add_child(extraEffect)
	extraEffect.global_position = number.global_position
	
	# Step 3: Pause for 2 seconds while everything stays in place
	await get_tree().create_timer(1.0).timeout
	
	# Step 4: Fade out and shrink simultaneously over 0.3 seconds
	var exitTween = get_tree().create_tween()
	exitTween.set_parallel(true)
	exitTween.tween_property(number, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN)
	exitTween.tween_property(number, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
	
	await exitTween.finished
	number.queue_free()
	
func display_burn_number(value: int, position: Vector2, isCrit: bool = false):

	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	var fontSize = 18
	var color = "#FF3333"
	
	number.label_settings.font = dmgFont
	number.label_settings.font_color = color
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 5
	number.label_settings.font_size = fontSize

	call_deferred("add_child", number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()

func display_dampen_number(value: int, position: Vector2, isCrit: bool = false):

	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	var fontSize = 12
	var color = "#E0F7FF"
	
	number.label_settings.font = dmgFont
	number.label_settings.font_color = color
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 6
	number.label_settings.font_size = fontSize

	call_deferred("add_child", number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()

func display_petrify_number(value: int, position: Vector2, isCrit: bool = false):

	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	var fontSize = 32
	var color = "#CDAD90"
	
	number.label_settings.font = dmgFont
	number.label_settings.font_color = color
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 5
	number.label_settings.font_size = fontSize

	call_deferred("add_child", number)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()
	
