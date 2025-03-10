extends Control

var normal_scale := Vector2(0.5, 0.5)
var hover_scale := Vector2(0.6, 0.6)

@onready var shopAnim = $AnimationPlayer

var hover_colors = {
	"WeaponStoreButton": Color(0.8, 0, 0),
	"HireStoreButton": Color(0.8, 0.8, 0),
	"LotteryStoreButton": Color(0, 0.8, 0)
}

var pressed_colors = {
	"WeaponStoreButton": Color(0.5, 0, 0),
	"HireStoreButton": Color(0.5, 0.5, 0),
	"LotteryStoreButton": Color(0, 0.5, 0)
}

var normal_color := Color(1, 1, 1)  # Default white
var darkened_color := Color(0.7, 0.7, 0.7)  # Slightly darker version of white (you can adjust this)

@onready var mainStoreMenu = $MainStoreMenu
@onready var weaponStoreMenu = $WeaponStoreMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for button in mainStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
		if button.is_in_group("mainUI"):
			button.connect("button_down", Callable(self, "mainShopButtonAnim"))
			button.connect("button_down", Callable(self, "getButtonName").bind(button))
	
	for button in weaponStoreMenu.get_children():
		if button.is_in_group("ui_button"):
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered").bind(button))
			button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited").bind(button))
			button.connect("button_down", Callable(self, "_on_button_down").bind(button))
			button.connect("button_up", Callable(self, "_on_button_up").bind(button))
		if button.is_in_group("back_button"):
			button.connect("button_down", Callable(self, "returnToMain").bind("Weapon"))
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_mouse_entered(button: TextureButton):
	var tween = get_tree().create_tween()
	tween.tween_property(button, "scale", hover_scale, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var target_color = hover_colors.get(button.name, normal_color)
	tween.tween_property(button, "modulate", target_color, 0.1) #Tween of target object, thing we want to edit, color, step

func _on_button_mouse_exited(button: TextureButton):
	var tween = get_tree().create_tween()
	tween.tween_property(button, "scale", normal_scale, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	var target_color = hover_colors.get(button.name, normal_color)
	tween.tween_property(button, "modulate", normal_color, 0.15) #Tween of target object, thing we want to edit, color, step
	
# Called when the button is pressed (darken effect)
func _on_button_down(button: TextureButton):
	var target_color = pressed_colors.get(button.name, normal_color)
	button.modulate = target_color

# Button released
func _on_button_up(button: TextureButton):
	var target_color = hover_colors.get(button.name, normal_color)
	button.modulate = target_color
	
func mainShopButtonAnim():
	if !shopAnim.is_playing():
		shopAnim.play("MainMenuSlideDown")
	else:
		shopAnim.queue("MainMenuSlideDown")  # Waits for the current animation to finish before playing

func returnToMain(uiType: String):
	if(uiType == "Weapon"):
		if(shopAnim.is_playing()):
			shopAnim.queue("WeaponMenuSlideDown")
		else:
			shopAnim.play("WeaponMenuSlideDown")
	
	if shopAnim.is_playing():	
		shopAnim.queue("MainMenuSlideIn")
	else:
		shopAnim.play("MainMenuSlideIn")

func getButtonName(button: TextureButton):
	if !button:  # Safety check
		print("um")
		return
	
	match button.name:
		"WeaponStoreButton":
			if shopAnim.is_playing():
				shopAnim.queue("WeaponMenuSlideIn")
			else:
				shopAnim.play("WeaponMenuSlideIn")
			print("WEAPON")
		"HireStoreButton":
			pass
		"LotteryStoreButton":
			pass
		_:
			print("Unknown button clicked:", button.name)  # Debugging fallback
	
	

