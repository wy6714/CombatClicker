extends TextureProgressBar

@onready var timer = $Timer
@onready var damageBar = $DamageBar

var health = 0 : set = _set_health

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

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damageBar.max_value = health
	damageBar.value = health

func _on_timer_timeout():
	damageBar.value = health # Damage value catches up to health valuepass # Replace with function body.
