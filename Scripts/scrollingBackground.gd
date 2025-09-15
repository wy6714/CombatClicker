extends Control

@export var white_background: Texture2D
@export var flashRedBackground: Texture2D
@onready var background_texture: TextureRect = $TextureRect

# Cycle length (seconds)
@export var day_length: float = 120.0
@export var DEBUG_FAST: bool = true
@export var DEBUG_DAY_LEN: float = 4.0

# ---- Color presets ----
@export var color_day: Color      = Color(0.16, 0.16, 0.16)	# #282828
@export var color_night: Color    = Color(0.07, 0.07, 0.07)	# #121212
@export var color_sunset_a: Color = Color(0.14, 0.08, 0.06)	# #241510
@export var color_sunset_b: Color = Color(0.18, 0.09, 0.09)	# #2d1817
@export var color_sunrise_a: Color= Color(0.22, 0.08, 0.15)	# #391526
@export var color_sunrise_b: Color= Color(0.13, 0.11, 0.21)	# #211d36

var time: float = 0.0
var sunset_color: Color = Color.WHITE
var sunrise_color: Color = Color.WHITE

var _flash_timer := 0.0
var _flash_duration := 0.06  # duration of red flash in seconds
var _saved_color := Color.WHITE
var _saved_texture: Texture2D = null

func _ready() -> void:
	
	$".".modulate = "ffffff"
	randomize()
	_pick_cycle_colors()
	if white_background:
		background_texture.texture = white_background
	else:
		print("Warning: white_background is not set; modulate will multiply whatever texture is present.")
	background_texture.modulate = color_day

func _process(delta):
	time += delta

	var effective_day_len = day_length
	if DEBUG_FAST:
		effective_day_len = DEBUG_DAY_LEN

	if time >= effective_day_len:
		time -= effective_day_len
		_pick_cycle_colors()

	# Handle flash or normal background
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			# restore background after flash
			background_texture.texture = _saved_texture
			background_texture.modulate = _saved_color
	else:
		_update_background(effective_day_len)


func _pick_cycle_colors() -> void:
	if randi() % 2 == 0:
		sunset_color = color_sunset_a
	else:
		sunset_color = color_sunset_b

	if randi() % 2 == 0:
		sunrise_color = color_sunrise_a
	else:
		sunrise_color = color_sunrise_b

func ease_smooth(t: float) -> float:
	# Ease in/out: 3t^2 - 2t^3; clamp to [0,1]
	t = clamp(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func color_lerp(a: Color, b: Color, t: float) -> Color:
	t = clamp(t, 0.0, 1.0)
	return Color(lerp(a.r, b.r, t),
				 lerp(a.g, b.g, t),
				 lerp(a.b, b.b, t),
				 lerp(a.a, b.a, t))

func _update_background(cycle_len: float) -> void:
	var t := fmod(time, cycle_len) / cycle_len	# 0..1

	# ---- Phase boundaries ----
	var day_end     := 0.40	# day holds until 40%
	var sunset_end  := 0.50	# quick sunset
	var night_end   := 0.90	# night duration
	var sunrise_end := 0.98	# margin for sunrise→day blend

	var c: Color = color_day
	if t < day_end:
		c = color_day
	elif t < sunset_end:
		var s := ease_smooth((t - day_end) / max(0.00001, (sunset_end - day_end)))
		c = color_lerp(color_day, sunset_color, s)
	elif t < night_end:
		var s := ease_smooth((t - sunset_end) / max(0.00001, (night_end - sunset_end)))
		c = color_lerp(sunset_color, color_night, s)
	elif t < sunrise_end:
		var s := ease_smooth((t - night_end) / max(0.00001, (sunrise_end - night_end)))
		c = color_lerp(color_night, sunrise_color, s)
	else:
		var s := ease_smooth((t - sunrise_end) / max(0.00001, (1.0 - sunrise_end)))
		c = color_lerp(sunrise_color, color_day, s)

	background_texture.modulate = c
	
func flashRed():
	if not flashRedBackground:
		return

	_saved_color = background_texture.modulate
	_saved_texture = background_texture.texture

	background_texture.texture = flashRedBackground
	background_texture.modulate = Color.WHITE

	_flash_timer = _flash_duration


func _on_timer_timeout():
	# Restore previous texture and modulate
	background_texture.texture = _saved_texture
	background_texture.modulate = _saved_color
