extends TextureProgressBar

@onready var timer = $Timer
@onready var damageBar = $DamageBar
@onready var breakBar = $BreakBar
@onready var breakDamageBar = $BreakBar/BreakDamageBar
@onready var breakTimer = $BreakBar/BreakTimer


var health = 0 : set = _set_health
var breakVal = 100: set = _set_break

func _process(delta):
	pass
	
	
func _set_health(newHealth):
	var prev_health = health
	health = min(max_value, newHealth)
	value = health
	
	if health <= 0:
		health = 0 # We are ded :<
	
	if health < prev_health: # We took damage
		timer.start()
	else:
		damageBar.value = health
		
func _set_break(newBreak):
	var prev_break = breakVal
	breakVal = min(breakBar.max_value, newBreak)
	breakBar.value = breakVal
	
	if breakVal <= 0:
		breakVal = 0
		print("broken!")
	
	if (breakVal < prev_break):
		breakTimer.start()
	else:
		print("um")

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damageBar.max_value = health
	damageBar.value = health
	
func init_break(_breakVal):
	breakVal = _breakVal
	breakBar.max_value = breakVal
	breakBar.value = breakVal
	breakDamageBar.max_value = breakVal
	breakDamageBar.value = breakVal

func _on_timer_timeout():
	damageBar.value = health # Damage value catches up to health valuepass # Replace with function body.

func _on_break_timer_timeout():
	breakDamageBar.value = breakVal
	print("uh break timer timeout")
	

