extends Control

@onready var dialogue_label = $DialogueBoxRectangle/DialogueLabel
@onready var type_timer = Timer.new()
var typing_speed := 0.02 # seconds per character
var is_typing := false
var full_text := ""
var current_index := 0
var is_processing: bool = false
var message_queue: Array = []
var should_clear
var current_tween

func type_message(message: String):
	message_queue.append(message)
	if not is_processing:
		_process_queue()

func _process_queue():
	is_processing = true
	should_clear = false

	# ensure visible (fade in if currently invisible)
	if modulate.a <= 0.0:
		# clear any visible text immediately so old message won't flash during fade-in
		if dialogue_label:
			dialogue_label.text = ""
		full_text = ""
		current_index = 0

		modulate.a = 0.0
		current_tween = create_tween()
		current_tween.tween_property(self, "modulate:a", 1.0, 0.25)
		await current_tween.finished
		current_tween = null
		# if someone cleared while fading in, bail
		if should_clear:
			is_processing = false
			return

	# process queue
	while message_queue.size() > 0:
		# bail early if cleared
		if should_clear:
			break

		full_text = message_queue.pop_front()
		current_index = 0
		if dialogue_label:
			dialogue_label.text = ""
		is_typing = true

		# type the message (bails quickly if should_clear)
		await _type_next_character()
		if should_clear:
			break
		is_typing = false

		# if there's another message already waiting, start it immediately (small gap optional)
		if message_queue.size() > 0:
			await get_tree().create_timer(0.1).timeout
			if should_clear:
				break
			continue

		# otherwise hold up to 4s but cancel hold immediately if a new message is queued or clear happened
		var hold_time := 4.0
		var elapsed := 0.0
		var step := 0.1
		while elapsed < hold_time:
			if message_queue.size() > 0 or should_clear:
				break
			await get_tree().create_timer(step).timeout
			elapsed += step

		if should_clear:
			break

		# if during the hold no new messages arrived, fade out
		if message_queue.size() == 0:
			current_tween = create_tween()
			current_tween.tween_property(self, "modulate:a", 0.0, 0.5)
			await current_tween.finished
			current_tween = null
			if should_clear:
				break

	# finished all queued messages or were cleared
	is_processing = false
	should_clear = false

# basic typewriter coroutine (await-based)
func _type_next_character():
	while current_index < full_text.length():
		dialogue_label.text += full_text[current_index]
		current_index += 1
		await get_tree().create_timer(typing_speed).timeout
		
# quick clear function: empties queue, kills tweens, clears text immediately
func clear_now():
	message_queue.clear()
	should_clear = true
	is_typing = false
	is_processing = false
	full_text = ""
	current_index = 0
	# kill any running tween so fades stop
	if current_tween != null:
		# SceneTreeTween has `kill()` in Godot 4
		current_tween.kill()
		current_tween = null
	# instantly hide & clear text
	modulate.a = 0.0
	if dialogue_label:
		dialogue_label.text = ""
