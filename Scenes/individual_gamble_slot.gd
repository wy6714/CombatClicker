extends Control
@export var glowColor: Color = Color(1.0, 0.5, 0.0, 0.4)
@onready var defaultColor: Color = Color.WHITE
@onready var glowPanel = $GlowPanel
@onready var slot = $TextureRect
@export var weight: int = 10

enum RewardType {POINTS, RADIANT_NEXT, UPGRADE_2, UPGRADE_4, CAPTURE_100, RADIANT_RATE_TEMP, RADIANT_RATE_PERM, EXP_BOOST}
@export var reward_type: RewardType = RewardType.POINTS
@export var reward_value: float = 0

@onready var player = get_node("/root/Main/Player")
@onready var playerMonsterList = get_node("/root/Main/Player/PlayerMonsterList")
@onready var playerStats = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")
@onready var enemyManager = get_node("/root/Main/EnemyManager")

func glow():
	glowPanel.visible = true
	glowPanel.modulate = glowColor
	slot.modulate = glowColor

func resetGlow():
	glowPanel.modulate = defaultColor
	glowPanel.visible = false
	slot.modulate = defaultColor

func apply_reward():
	print("apply_reward called, enemyManager = ", enemyManager)
	match reward_type:
		#
		RewardType.POINTS:
			player.transactionScoreUpdate(int(reward_value)) 
		#
		RewardType.RADIANT_NEXT:
			enemyManager.forceNextRadiant += 1  # was: = true (type mismatch, int expected)
		
		#
		RewardType.UPGRADE_2:
			for party_member in get_tree().get_nodes_in_group("PartyMember"):
				party_member.upgradePoints += 2		
				party_member.totalAccumulatedUpgradePoints += 2
			
			playerStats.upgradePoints += 2
			player.totalUpgradePoints += 2
			
		#
		RewardType.UPGRADE_4:
			for party_member in get_tree().get_nodes_in_group("PartyMember"):
				party_member.upgradePoints += 4		
				party_member.totalAccumulatedUpgradePoints += 4
				
			playerStats.upgradePoints += 4
			player.totalUpgradePoints += 4
	#
		RewardType.CAPTURE_100:
			if is_instance_valid(player.currentEnemy):
				player.currentEnemy.captureRate = 100
			else:
				enemyManager.forceNextCapture += 1
		
		#
		RewardType.RADIANT_RATE_TEMP: 
			enemyManager.tempRadiantBoost = 5 # +5% for next 3 enemies (SHOULD BE 5)
			enemyManager.tempRadiantBoostCounter = 3
		#
		RewardType.RADIANT_RATE_PERM:
			enemyManager.permanentRadiantRate += 0.5  # was: player.radiantRate (wrong var entirely) SHOULD BE 0.5
		
		RewardType.EXP_BOOST:
			player.expMultiplier += 0.1 # SHOULD BE 0.1
