extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/SCORE/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var playerStats = get_node("/root/Main/PartyMemberPlayer")
@onready var playerMemberIcon = get_node("/root/Main/PartyMemberPlayer")
@onready var shopUI = get_node("/root/Main/ShopUI")
@export var partyMemberCost: int = 1000
@export var partyMemberCostMult: float = 1.0
@onready var partyMemberTemplate = preload("res://Scenes/PartyMember.tscn")
@onready var partyMembers = []
@onready var partyMemberCount = 0
@onready var partyMemberMax = 5

@onready var lockedButtonList =  [
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade1"), 
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade2"), 
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade3"),
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade4"),
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade5"),
get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/PartyMemberUpgrade6")
]

@onready var upgradePointFeedbackPopup = preload("res://Scenes/PlusOneUpgradePoint.tscn")

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
			partyMember.memberNumber = partyMemberCount
			print(partyMember.memberNumber)
			partyMember.position.x = playerMemberIcon.position.x
			partyMember.position.x += 155 * partyMemberCount
			get_tree().root.add_child(partyMember)
			partyMemberCostMult += 1
			partyMemberCost *= partyMemberCostMult
			shopUI.updateRecruitmentPrices()
			unlockMemberUpgrades(lockedButtonList[partyMemberCount - 1], partyMemberCount)

func unlockMemberUpgrades(btn: TextureButton, number: int):
	btn.visible = true
	var label = btn.get_node("Label")
	label.text = "Member" + str(number)
	btn.modulate = Color(1, 1, 1) # Become white
	
	if btn.is_in_group("unlocked") == false: # If theyre not in "unlocked" group, change that
		btn.add_to_group("unlocked")
		
	# create a Callable that calls _on_store_button_pressed(button)
	var cb := Callable(self, "on_party_member_upgrade_pressed").bind(btn)
	if not btn.pressed.is_connected(cb):
		btn.pressed.connect(cb)
			
		
	shopUI.updateUnlockedButton()
	
func on_party_member_upgrade_pressed(button) -> void:
	var name_str = button.name #Get name, so we can strip it to get the number
	var num_str = name_str.trim_prefix("PartyMemberUpgrade")
	var member_num = int(num_str)
	print("clicked??????")
	
	partyMemberUpgradeButton(member_num, button)
	
func partyMemberUpgradeButton(memberNum: int, button):
	for partyMember in get_tree().get_nodes_in_group("PartyMember"):
		if partyMember.memberNumber == memberNum:
			if player.score >= partyMember.upgradeCost:
				partyMember.upgradePoints += 1
				player.score -= partyMember.upgradeCost
				player.scoreNumber.text = str(player.score)
				partyMember.upgradeCost *= 2

				var popup := upgradePointFeedbackPopup.instantiate()
				# Same global handling as player
				popup.global_position = partyMember.upgradePointFeedbackLocation.global_position
				get_tree().current_scene.add_child(popup)

				var start_pos = popup.global_position
				var end_pos = start_pos + Vector2(20, -100)

				var tween := create_tween()
				tween.tween_property(
					popup,
					"global_position",   # animate global position
					end_pos,
					0.7
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

				if button.has_node("Cost"):
					var cost_label := button.get_node("Cost") as Label
					if cost_label:
						cost_label.text = str(partyMember.upgradeCost)
					else:
						push_warning("'Cost' node exists but isn't a Label; can't set .text")
				else:
					push_warning("No 'Cost' node found under partyMember; UI not updated")
			else:
				print("Player doesnt have enough money..")

			


