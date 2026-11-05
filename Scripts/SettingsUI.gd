extends Control

@onready var master_volume_slider = $MasterVolumeSlider
@onready var music_volume_slider = $MusicVolumeSlider
@onready var sfx_volume_slider = $SFXVolumeSlider
@onready var settingsCogAnim = $SettingsCogAnim
@onready var settingsAnim = $SettingsAnim
@onready var sfxTest = $SettingSFXTest
@onready var fullScreenText = $Fullscreen
@onready var fullScreenButton = $Fullscreen/DisplayOptionButton
@onready var windowedText = $Windowed
@onready var windowedButton = $Windowed/DisplayOptionButton2
@onready var windowed1xText = $Windowed1x
@onready var windowed1xButton = $Windowed1x/DisplayOptionButton2
@onready var windowed2xText = $Windowed2x
@onready var windowed2xButton = $Windowed2x/DisplayOptionButton2
@onready var windowed3xText = $Windowed3x
@onready var windowed3xButton = $Windowed3x/DisplayOptionButton2

var current_display_mode = "windowed_s"
var current_windowed_scale = "S"
var base_window_size = Vector2(1152, 648)

var is_fullscreen = false
var is_maximized = false

var _last_known_mode
var _syncing_from_os = false

func _ready():
	
	# Set focus mode so sliders don't stay highlighted
	master_volume_slider.focus_mode = Control.FOCUS_NONE
	music_volume_slider.focus_mode = Control.FOCUS_NONE
	sfx_volume_slider.focus_mode = Control.FOCUS_NONE
	
	# Set initial values
	master_volume_slider.value = 100
	music_volume_slider.value = 100
	sfx_volume_slider.value = 100
	
	# Connect signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Display mode buttons
	fullScreenButton.pressed.connect(_on_fullscreen_button_pressed)
	windowedButton.pressed.connect(_on_windowed_button_pressed)
	windowed1xButton.pressed.connect(_on_windowed_s_button_pressed)
	windowed2xButton.pressed.connect(_on_windowed_m_button_pressed)
	windowed3xButton.pressed.connect(_on_windowed_l_button_pressed)
	
	# Safety net for OS-driven window changes
	get_window().size_changed.connect(_on_window_size_changed)
	
	# Set initial display state and apply
	apply_display_mode()
	update_display_ui()
	
	_last_known_mode = get_window().mode

func _unhandled_input(event):
	if event.is_action_pressed("ui_fullscreen_toggle"):
		if is_fullscreen:
			_on_windowed_button_pressed()
		else:
			_on_fullscreen_button_pressed()
		get_viewport().set_input_as_handled()

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	sfxTest.play()
	
func _on_settings_cog_button_down():
	settingsCogAnim.play("CogSpin")

func _on_close_button_button_down():
	settingsAnim.play("SettingsClose")

func openMenu():
	visible = true
	settingsAnim.play("SettingsOpen")

func _on_quit_button_button_down():
	print("Exiting Game :(")
	get_tree().quit()

# -------------------------------------------------------------------------
# DISPLAY MODE FUNCTIONS
# -------------------------------------------------------------------------

func _on_fullscreen_button_pressed():
	is_fullscreen = true
	is_maximized = false
	current_display_mode = "fullscreen"
	
	var window = get_window()
	window.borderless = true
	await get_tree().process_frame
	await get_tree().process_frame  # let the OS actually strip the border first
	
	window.size = DisplayServer.screen_get_size(window.current_screen)
	window.position = DisplayServer.screen_get_position(window.current_screen)
	
	_last_known_mode = window.mode
	update_display_ui()

func _on_windowed_button_pressed():
	is_fullscreen = false
	is_maximized = false
	current_display_mode = "windowed_s"
	current_windowed_scale = "S"
	force_windowed()
	update_display_ui()

func _on_windowed_s_button_pressed():
	if current_display_mode.begins_with("windowed"):
		is_fullscreen = false
		is_maximized = false
		current_windowed_scale = "S"
		current_display_mode = "windowed_s"
		force_windowed()
		update_display_ui()

func _on_windowed_m_button_pressed():
	if current_display_mode.begins_with("windowed"):
		is_fullscreen = false
		is_maximized = false
		current_windowed_scale = "M"
		current_display_mode = "windowed_m"
		force_windowed()
		update_display_ui()

func _on_windowed_l_button_pressed():
	if current_display_mode.begins_with("windowed"):
		is_fullscreen = false
		is_maximized = false
		current_windowed_scale = "L"
		current_display_mode = "windowed_l"
		force_windowed()
		update_display_ui()

func force_windowed():
	var window = get_window()
	window.borderless = false
	
	# Force a real mode change so Windows fully recreates the title bar
	# decorations, instead of just patching the borderless flag in place
	# (this is what was causing the "old Windows" chrome look).
	window.mode = Window.MODE_MINIMIZED
	await get_tree().process_frame
	window.mode = Window.MODE_WINDOWED
	await get_tree().process_frame
	await get_tree().process_frame
	
	match current_windowed_scale:
		"S": window.size = Vector2(1152, 648)
		"M": window.size = Vector2(1440, 810)
		"L": window.size = Vector2(1728, 972)
	
	# Use the USABLE screen rect (excludes taskbar) so the title bar
	# never lands somewhere off-screen/unreachable.
	var usable_rect = DisplayServer.screen_get_usable_rect(window.current_screen)
	window.position = Vector2i(
		usable_rect.position.x + (usable_rect.size.x - window.size.x) / 2,
		usable_rect.position.y + (usable_rect.size.y - window.size.y) / 2
	)
	
	_last_known_mode = window.mode

func _on_window_size_changed():
	var window = get_window()
	var actual_mode = window.mode
	
	if actual_mode == _last_known_mode:
		return
	
	_last_known_mode = actual_mode
	_syncing_from_os = true
	
	if actual_mode == Window.MODE_MAXIMIZED:
		is_fullscreen = false
		is_maximized = true
		current_display_mode = "windowed_" + current_windowed_scale.to_lower()
	elif actual_mode == Window.MODE_WINDOWED and not window.borderless:
		is_fullscreen = false
		is_maximized = false
		current_display_mode = "windowed_" + current_windowed_scale.to_lower()
	
	update_display_ui()
	_syncing_from_os = false

func apply_display_mode():
	if _syncing_from_os:
		return
	
	var window = get_window()
	
	if current_display_mode == "fullscreen":
		window.borderless = true
		window.mode = Window.MODE_WINDOWED
		window.size = DisplayServer.screen_get_size(window.current_screen)
		window.position = DisplayServer.screen_get_position(window.current_screen)
	else:
		window.borderless = false
		window.mode = Window.MODE_WINDOWED
		match current_windowed_scale:
			"S": window.size = Vector2(1152, 648)
			"M": window.size = Vector2(1440, 810)
			"L": window.size = Vector2(1728, 972)
		
		var usable_rect = DisplayServer.screen_get_usable_rect(window.current_screen)
		window.position = Vector2i(
			usable_rect.position.x + (usable_rect.size.x - window.size.x) / 2,
			usable_rect.position.y + (usable_rect.size.y - window.size.y) / 2
		)
	
	_last_known_mode = window.mode

func update_display_ui():
	if current_display_mode == "fullscreen":
		fullScreenText.text = "Fullscreen:\nON"
		windowedText.text = "Windowed:\nOFF"
	else:
		fullScreenText.text = "Fullscreen:\nOFF"
		windowedText.text = "Windowed:\nON"
	
	fullScreenButton.button_pressed = (current_display_mode == "fullscreen")
	fullScreenText.modulate = Color.WHITE if current_display_mode == "fullscreen" else Color(0.3, 0.3, 0.3)
	
	windowedButton.button_pressed = current_display_mode.begins_with("windowed")
	windowedText.modulate = Color.WHITE if current_display_mode.begins_with("windowed") else Color(0.3, 0.3, 0.3)
	
	var windowed_active = current_display_mode.begins_with("windowed")
	
	windowed1xButton.disabled = not windowed_active
	windowed1xButton.button_pressed = (current_display_mode == "windowed_s")
	windowed1xText.modulate = Color.WHITE if windowed_active else Color(0.3, 0.3, 0.3)
	windowed1xText.text = "S"
	
	windowed2xButton.disabled = not windowed_active
	windowed2xButton.button_pressed = (current_display_mode == "windowed_m")
	windowed2xText.modulate = Color.WHITE if windowed_active else Color(0.3, 0.3, 0.3)
	windowed2xText.text = "M"
	
	windowed3xButton.disabled = not windowed_active
	windowed3xButton.button_pressed = (current_display_mode == "windowed_l")
	windowed3xText.modulate = Color.WHITE if windowed_active else Color(0.3, 0.3, 0.3)
	windowed3xText.text = "L"
