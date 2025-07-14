extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var playerMemberIcon = get_node("/root/Main/PartyMemberPlayer")
@onready var shopUI = get_node("/root/Main/ShopUI")
@export var partyMemberCost: int = 1000
@export var partyMemberCostMult: float = 1.0
@onready var partyMemberTemplate = preload("res://Scenes/PartyMember.tscn")
@onready var partyMembers = []
@onready var partyMemberCount = 0
@onready var partyMemberMax = 5

@onready var lockedButtonList =  [
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember1Upgrade"), 
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember2Upgrade"), 
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember3Upgrade"),
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember4Upgrade"),
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember5Upgrade"),
get_node("/root/Main/ShopUI/HireStoreMenu/PartyMember6Upgrade")
]



func _on_button_down(): # (Buying a party member)
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
		if(player.score >= partyMemberCost):
			player.transactionScoreUpdate(partyMemberCost * -1)
			var partyMember = partyMemberTemplate.instantiate()
			partyMembers.append(partyMember)
			partyMemberCount += 1
			partyMember.position.x += 191 * partyMemberCount
			get_tree().root.add_child(partyMember)

func instantiateSelf():
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
			var partyMember = partyMemberTemplate.instantiate()
			partyMembers.append(partyMember)
			partyMemberCount += 1
			get_tree().root.add_child.call_deferred(partyMember)
			
func newPartyMember():
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
		if(player.score >= partyMemberCost):
			player.transactionScoreUpdate(partyMemberCost * -1)
			var partyMember = partyMemberTemplate.instantiate()
			partyMembers.append(partyMember)
			partyMemberCount += 1
			partyMember.position.x = playerMemberIcon.position.x
			partyMember.position.x += 155 * partyMemberCount
			get_tree().root.add_child(partyMember)
			partyMemberCostMult += 1
			partyMemberCost *= partyMemberCostMult
			shopUI.updateRecruitmentPrices()
			unlockMemberUpgrades(lockedButtonList[partyMemberCount - 1], partyMemberCount)

func unlockMemberUpgrades(btn: TextureButton, number: int):
	var label = btn.get_node("Label")
	label.text = "Member" + str(number)
	btn.modulate = Color(1, 1, 1) # Become white
	
	if btn.is_in_group("unlocked") == false: # If theyre not in "unlocked" group, change that
		btn.add_to_group("unlocked")
		
	shopUI.updateUnlockedButton()
