extends Button

@onready var scoreText = get_node("/root/Main/Scoreboard/SCORE/ScoreNumber")
@onready var player = get_node("/root/Main/Player")
@onready var playerStats = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")
@onready var playerMemberIcon = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")
@onready var shopUI = get_node("/root/Main/ShopUI")
@onready var partyManager = get_node("/root/Main/PartyMemberHolder")
@onready var clipPanel = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel")
@export var partyMemberCost: int = 1000
@export var partyMemberCostMult: float = 1.0
@onready var partyMemberTemplate = preload("res://Scenes/PartyMember.tscn")
@onready var partyMemberCount = 0
@onready var partyMemberMax = 4

@onready var lockedButtonList: Array =  []

@onready var upgradePointFeedbackPopup = preload("res://Scenes/PlusOneUpgradePoint.tscn")
@onready var recruitButton = get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/RecruitButton")
@onready var gambleButton = get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/GambleButton")

@onready var statHolder = get_tree().get_first_node_in_group("StatHolder")

@export var memberUpgradePointScalar = 1.25
@export var memberUpgradePointCostCap = 99999.0

func _ready():
	var container = get_node("/root/Main/ShopUI/MainStoreMenu/HireStoreMenu/CharacterListContents")
	for i in range(1, partyMemberMax + 1):
		lockedButtonList.append(container.get_node("PartyMemberUpgrade" + str(i)))
		
# NOTE: this handler still does its own positioning (191 * count) and never
# went through PartyManager even before this refactor — flag if this is dead
# code you want removed, or if something else still calls it.
func _on_button_down(): # (Buying a party member)
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
		if(player.score >= partyMemberCost):
			player.transactionScoreUpdate(partyMemberCost * -1)
			var partyMember = partyMemberTemplate.instantiate()
			partyMemberCount += 1
			partyMember.position.x += 191 * partyMemberCount
			get_tree().root.add_child(partyMember)

func instantiateSelf():
	if(partyMemberCount <= partyMemberMax): # (Can only have so many party members, for now at least idk)
			var partyMember = partyMemberTemplate.instantiate()
			partyMemberCount += 1
			get_tree().root.add_child.call_deferred(partyMember)

func newPartyMember() -> bool:
	if partyMemberCount >= partyMemberMax:
		return false

	if player.score >= partyMemberCost:
		player.transactionScoreUpdate(partyMemberCost * -1)
		var partyMember = partyMemberTemplate.instantiate()
		partyMemberCount += 1
		
		if(partyMemberCount >= partyMemberMax):
			recruitButton.visible = false
			gambleButton.visible = true
			
		clipPanel.add_child(partyMember)
		partyManager.addMember(partyMember)
		if statHolder != null:
			statHolder.updateSelectionArrowVisibility()
		partyMemberCostMult += 1
		partyMemberCost *= partyMemberCostMult
		shopUI.updateRecruitmentPrices()
		unlockMemberUpgrades(lockedButtonList[partyMemberCount - 1], partyMemberCount)

		return true
	else:
		print("Player doesnt have enough money..")
		shopUI.playNotEnoughMoneySE()
		return false

	if(partyMemberCount <= partyMemberMax):
		if(player.score >= partyMemberCost):
			player.transactionScoreUpdate(partyMemberCost * -1)
			var partyMember = partyMemberTemplate.instantiate()
			partyMemberCount += 1
			print(partyMemberCount)

			clipPanel.add_child(partyMember)
			partyManager.addMember(partyMember)
			if statHolder != null:
				statHolder.updateSelectionArrowVisibility()

			partyMemberCostMult += 1
			partyMemberCost *= partyMemberCostMult
			shopUI.updateRecruitmentPrices()
			unlockMemberUpgrades(lockedButtonList[partyMemberCount - 1], partyMemberCount)
			
			if partyMemberCount >= partyMemberMax:
				if shopUI and shopUI.recruitButton:
					shopUI.recruitButton.disabled = true
					var costLabel = shopUI.recruitButton.get_node_or_null("Cost")
					if costLabel:
						costLabel.text = ""
					var recruitLabel = shopUI.recruitButton.get_node_or_null("Label")
					if recruitLabel:
						recruitLabel.text = "???"

			return true
		else:
			print("Player doesnt have enough money..")
			shopUI.playNotEnoughMoneySE()
			return false
	
	return false


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
	
	partyMemberUpgradeButton(member_num, button)
	
func partyMemberUpgradeButton(memberNum: int, button):
	var partyMember = partyManager.get_member_by_number(memberNum)
	if partyMember == null:
		push_warning("No party member found for number " + str(memberNum))
		return

	if player.score >= partyMember.upgradePointCost:
		partyMember.upgradePoints += 1
		player.score -= partyMember.upgradePointCost
		player.scoreNumber.text = str(player.score)

		partyMember.upgradePointCost = min(
			round(partyMember.upgradePointCost * memberUpgradePointScalar / 50.0) * 50,
			memberUpgradePointCostCap
		)

		var popup := upgradePointFeedbackPopup.instantiate()
		popup.global_position = partyMember.upgradePointFeedbackLocation.global_position
		get_tree().current_scene.add_child(popup)

		var start_pos = popup.global_position
		var end_pos = start_pos + Vector2(20, -100)

		var tween := create_tween()
		tween.tween_property(
			popup,
			"global_position",
			end_pos,
			0.7
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		shopUI.playMemberUpgradeSE()

		if button.has_node("Cost"):
			var cost_label := button.get_node("Cost") as Label
			if cost_label:
				cost_label.text = str(partyMember.upgradePointCost)
			else:
				push_warning("'Cost' node exists but isn't a Label; can't set .text")
		else:
			push_warning("No 'Cost' node found under partyMember; UI not updated")
	else:
		print("Player doesnt have enough money..")
		shopUI.playNotEnoughMoneySE()
