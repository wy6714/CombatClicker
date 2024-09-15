extends Node2D

@export var strength: int = 1
@export var critRate: int = 5
@export var critDamage: int = 2
@export var damage: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func determineDamage():
	damage = strength
	var rng = randi_range(1, 100)
	if(rng <= critRate):
		damage = damage * critDamage
	
