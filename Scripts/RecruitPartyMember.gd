extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@export var partyMemberCost: int = 100
@onready var partyMemberTemplate = preload("res://Scenes/PartyMember.tscn")
@onready var partyMembers = []
@onready var partyMemberCount = 0
@onready var partyMemberMax = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_down(): # (Buying a party member)
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
		if(player.score >= partyMemberCost):
			player.transactionScoreUpdate(partyMemberCost * -1)
			var partyMember = partyMemberTemplate.instantiate()
			partyMembers.append(partyMember)
			partyMemberCount += 1
			partyMember.position.x += 130 * partyMemberCount
			get_tree().root.add_child(partyMember)

func instantiateSelf():
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
			var partyMember = partyMemberTemplate.instantiate()
			partyMembers.append(partyMember)
			partyMemberCount += 1
			get_tree().root.add_child.call_deferred(partyMember)
