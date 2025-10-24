extends Node

#THIS FUNCTION IS AUTOLOADED. It is not quite attached to anything, all nodes will have access to it
#(HOPEFULLY...)

@onready var dmgFont = preload("res://Fonts/Press_Start_2P/PressStart2P-Regular.ttf")
@onready var damageText = preload("res://Scenes/damage_text.tscn")
@onready var bigHitCritAudio = preload("res://Audio/CritBigHit2.mp3")

# Helper to build a damage number label with consistent setup
func _create_number_label(value: int, position: Vector2, font_size: int, color: Color, outline_size: int) -> Label:
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()
	number.label_settings.font = dmgFont
	number.label_settings.font_size = font_size
	number.label_settings.font_color = color
	number.label_settings.outline_color = Color.BLACK
	number.label_settings.outline_size = outline_size
	call_deferred("add_child", number)
	return number

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
		color = "#CC0808"
		number.label_settings.font_size = critFontSize
	else:
		number.label_settings.font_size = fontSize

	if value == 0:
		color = "#FFF8"
		number.label_settings.font_size = fontSize

	number.label_settings.font = dmgFont
	number.label_settings.font_color = color
	number.label_settings.outline_color = "#000"
	if isCrit:
		number.label_settings.outline_size = 12
	else:
		number.label_settings.outline_size = 8

	# tiny horizontal jitter so numbers don't perfectly overlap
	var jitter_x = (randi() % 11) - 5
	number.global_position = position + Vector2(jitter_x, 0)

	call_deferred("add_child", number)

	# make new numbers fully opaque initially
	number.modulate = Color(1, 1, 1, 1)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	# Slightly fade older numbers so new ones pop more.
	# Tweak these if you want stronger/weaker or faster/slower fades.
	var fade_amount = 0.25        # how much alpha to remove from older numbers
	var fade_time = 0.8          # how long that fade takes (seconds)
	var min_alpha = 0.35         # never go below this so numbers remain readable

	for child in get_children():
		# only affect other Label nodes created here
		if child is Label and child != number:
			var cur_alpha = child.modulate.a
			var target_alpha = cur_alpha - fade_amount
			if target_alpha < min_alpha:
				target_alpha = min_alpha
			# tween their alpha down a bit over time
			get_tree().create_tween().tween_property(child, "modulate:a", target_alpha, fade_time)

	# starting scale for a punchy pop (bigger for crits)
	if isCrit:
		number.scale = Vector2(0.6, 0.6)
	else:
		number.scale = Vector2(0.45, 0.45)

	# rotation: bigger random tilt for crits
	var rot_amount = 0.0
	if isCrit:
		rot_amount = deg_to_rad((randf() * 18.0) - 9.0)
	else:
		rot_amount = deg_to_rad((randf() * 10.0) - 5.0)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Crit pop vs normal pop
	if isCrit:
		tween.tween_property(number, "scale", Vector2(1.6, 1.6), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "scale", Vector2(0.95, 0.95), 0.10).set_ease(Tween.EASE_IN).set_delay(0.06)
		tween.tween_property(number, "scale", Vector2(1.08, 1.08), 0.06).set_ease(Tween.EASE_OUT).set_delay(0.16)
	else:
		tween.tween_property(number, "scale", Vector2(1.25, 1.25), 0.08).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "scale", Vector2(0.95, 0.95), 0.12).set_ease(Tween.EASE_IN).set_delay(0.08)
		tween.tween_property(number, "scale", Vector2(1, 1), 0.08).set_ease(Tween.EASE_OUT).set_delay(0.20)

	# tilt
	tween.tween_property(number, "rotation", rot_amount, 0.18).set_ease(Tween.EASE_OUT)

	# float and final shrink; crits move up more and hang longer
	var fade_delay = 0.45
	if isCrit:
		tween.tween_property(number, "position:y", number.position.y - 36, 0.30).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "position:y", number.position.y - 8, 0.60).set_ease(Tween.EASE_IN).set_delay(0.30)
		tween.tween_property(number, "scale", Vector2.ZERO, 0.28).set_ease(Tween.EASE_IN).set_delay(0.7)
		fade_delay = 0.65
	else:
		tween.tween_property(number, "position:y", number.position.y - 24, 0.25).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
		tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
		fade_delay = 0.45

	# final fade out for this number at the end of its life (unchanged behavior)
	tween.tween_property(number, "modulate:a", 0.0, 0.25).set_delay(fade_delay)

	await tween.finished
	number.queue_free()


func display_burn_number(value: int, position: Vector2, isCrit: bool = false):
	var number = _create_number_label(value, position, 18, Color.html("#FF3333"), 6)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 24, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()


func display_dampen_number(value: int, position: Vector2, isCrit: bool = false):
	var number = _create_number_label(value, position, 12, Color.html("#E0F7FF"), 6)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 24, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()


func display_petrify_number(value: int, position: Vector2, isCrit: bool = false):
	var number = _create_number_label(value, position, 32, Color.html("#CDAD90"), 6)

	await number.resized
	number.pivot_offset = Vector2(number.size / 2)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 24, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)

	await tween.finished
	number.queue_free()
	
func display_big_number(value: int, position: Vector2, isCrit: bool = false):
	var number = Label.new()
	# Place the number at the center position with your desired X offset (-75)
	number.global_position = position + Vector2(-75, 0)
	number.text = str(value)
	number.z_index = 10
	number.label_settings = LabelSettings.new()

	# Set alignment to center
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Font size settings
	var baseFontSize = 68
	var critFontSize = 72

	# Set font and styling
	number.label_settings.font = dmgFont
	number.label_settings.outline_size = 12
	if isCrit:
		number.label_settings.font_size = critFontSize
		number.label_settings.font_color = Color("#C49A12")  # Gold for crits
	else:
		number.label_settings.font_size = baseFontSize
		number.label_settings.font_color = Color("#8E1A1A")  # Red for normal hits

	# Always white outline
	number.label_settings.outline_color = Color("#FFF")

	call_deferred("add_child", number)

	await number.resized
	number.pivot_offset = number.size / 2

	# Starting scale for the pop effect
	if isCrit:
		number.scale = Vector2(0.6, 0.6)
	else:
		number.scale = Vector2(0.5, 0.5)

	# Random slight rotation
	var rot_amount: float
	if isCrit:
		rot_amount = deg_to_rad((randf() * 6.0) - 3.0) # -3° to +3° tilt
	else:
		rot_amount = deg_to_rad((randf() * 4.0) - 2.0) # -2° to +2° tilt

	# Bounce + float tween
	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	# Bounce scale sequence
	if isCrit:
		tween.tween_property(number, "scale", Vector2(1.7, 1.7), 0.08).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "scale", Vector2(0.95, 0.95), 0.10).set_ease(Tween.EASE_IN).set_delay(0.08)
		tween.tween_property(number, "scale", Vector2(1.05, 1.05), 0.08).set_ease(Tween.EASE_OUT).set_delay(0.18)
	else:
		tween.tween_property(number, "scale", Vector2(1.3, 1.3), 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(number, "scale", Vector2(0.95, 0.95), 0.12).set_ease(Tween.EASE_IN).set_delay(0.1)
		tween.tween_property(number, "scale", Vector2(1.0, 1.0), 0.08).set_ease(Tween.EASE_OUT).set_delay(0.22)

	# Rotation
	tween.tween_property(number, "rotation", rot_amount, 0.2).set_ease(Tween.EASE_OUT)

	# Float upward
	tween.tween_property(
		number, "position:y", number.position.y - 64, 0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# If crit, start the flash+sound coroutine concurrently (doesn't block)
	if isCrit:
		_crit_flash(number)  # start flash in background

	await tween.finished

	# Extra damage effect spawn
	var extraEffect = damageText.instantiate()
	number.add_child(extraEffect)
	extraEffect.global_position = number.global_position

	# Hold briefly
	await get_tree().create_timer(1.0).timeout

	# Fade out and shrink simultaneously
	var exitTween = get_tree().create_tween()
	exitTween.set_parallel(true)
	exitTween.tween_property(number, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN)
	exitTween.tween_property(number, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)

	await exitTween.finished
	number.queue_free()


# helper coroutine: flashes the label white briefly and plays sound (crit-only)
func _crit_flash(number: Label) -> void:
	# wait ~0.2s into the pop animation
	await get_tree().create_timer(0.5).timeout

	# remember original color and set to white
	var original_color = number.label_settings.font_color
	number.label_settings.font_color = Color(1, 1, 1)

	# play the crit audio (one-shot)
	var s := AudioStreamPlayer.new()
	s.stream = bigHitCritAudio
	add_child(s)
	s.play()

	# short white flash duration
	await get_tree().create_timer(0.13).timeout

	# restore original color
	if is_instance_valid(number):
		number.label_settings.font_color = original_color

	# cleanup the player after a short delay (let the clip finish)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(s):
		s.queue_free()
