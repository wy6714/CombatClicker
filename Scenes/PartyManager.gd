extends Node

# ============================================================
# PartyManager
#
# Owns the single source of truth for "who is in the party, and
# where do they currently sit on screen." Replaces the old model
# where RecruitPartyMember positioned members once at spawn time
# and never touched them again.
#
# Roster model:
#   roster[0]        = the player node
#   roster[1..n]     = party members, in recruit order (memberNumber == index)
#
# Screen model (PARTY MEMBERS):
#   getSlotX(i) maps a SLOT INDEX (0 = leftmost visible slot) to a
#   pixel X position, relative to baseX/baseY (the player's actual
#   position). scrollIndex says which roster index currently sits in
#   slot 0. So:
#       screen_slot_for(rosterIndex) = rosterIndex - scrollIndex
#       position.x = getSlotX(rosterIndex - scrollIndex)
#       position.y = baseY (members sit on the same horizontal line as
#       the player)
#
#   After placing each member, we also stamp member.original_position
#   to match — PartyMember.gd's hover-in/out tweens animate back to
#   original_position, and that field is normally captured once in
#   _ready() BEFORE this script ever gets a chance to position the
#   node. Without re-stamping it here, hovering would snap members
#   back to their scene-default (0,0)-ish spawn position instead of
#   their actual correct resting slot.
#
#   Only roster entries whose screen slot falls within
#   [0, visibleSlotCount - 1] are positioned/visible at all;
#   everything else is just data sitting off-screen until scrolled in.
#
#   visibleSlotCount = 5: player (slot 0) + 4 full party member slots
#   (slots 1-4). Previously this was 6, which included a 5th party
#   member slot that only ever rendered half-clipped at the panel's
#   edge — that partial slot fully vanished the instant the roster
#   scrolled, which read as a glitch. Dropping to 5 removes that
#   half-slot state entirely: 4 full party members visible at once,
#   nothing partially rendered, exactly matching "4 teammates is the
#   flawless baseline, the 5th triggers a shift."
#
# Screen model (SPOTLIGHT):
#   The spotlight tracks the newest member's slot for the first
#   spotlightSlot recruits (1, 2, 3, 4...), then freezes at
#   spotlightSlot permanently once the roster grows past it —
#   new members beyond that point arise into that same fixed slot
#   while the rest of the roster visually shifts to make room.
#   Only its X is managed here — its Y is left as whatever was
#   authored in the scene, since that was already correct.
# ============================================================

@export var slotSpacing: float = 155.0
@export var visibleSlotCount: int = 5 # player + 4 party members fully visible at once (no half-clipped slot)
@export var spotlightSlot: int = 4 # Slot the spotlight progresses toward and then freezes at

# baseX/baseY are derived in _ready() from the player's actual position,
# since slot 0 in the party-member system IS the player.
var baseX: float = 0.0
var baseY: float = 0.0

# spotlightStartX is captured once from wherever the Spotlight node
# already sits in the scene (its authored editor position) — NOT derived
# from baseX. The spotlight's resting X is its own independent offset,
# unrelated to the player's position.
var spotlightStartX: float = 0.0

@onready var shopUI = get_node("/root/Main/ShopUI")
@onready var leftArrow = get_node("/root/Main/LeftSelectionArrow")
@onready var rightArrow = get_node("/root/Main/RightSelectionArrow")
@onready var playerMemberIcon = get_node("/root/Main/PartyMemberHolder/PartyMemberClipPanel/PartyMemberPlayer")

var roster: Array = [] # index 0 = player, 1..n = party members
var scrollIndex: int = 0


func _ready() -> void:
	baseX = playerMemberIcon.position.x
	baseY = playerMemberIcon.position.y

	if shopUI and shopUI.has_node("Spotlight"):
		spotlightStartX = shopUI.get_node("Spotlight").position.x

	# Reserve slot 0 for the player. roster[0] is the actual player node,
	# so it scrolls along with party members like any other roster entry.
	roster.resize(1)
	roster[0] = playerMemberIcon

	# Set the initial arrow state.
	updateSelectionArrowStates()


func setPlayerNode(playerNode: Node) -> void:
	roster[0] = playerNode
	repositionAll()


# ------------------------------------------------------------
# Slot <-> pixel math for PARTY MEMBERS ONLY. Swap this one
# function out later if you move to marker/anchor nodes instead
# of fixed spacing.
# ------------------------------------------------------------
func getSlotX(slotIndex: int) -> float:
	return baseX + (slotIndex * slotSpacing)


func screenSlotFor(rosterIndex: int) -> int:
	return rosterIndex - scrollIndex


# ------------------------------------------------------------
# Adding a member. Called by RecruitPartyMember after it has
# already spent the money and instantiated the scene —
# this function only handles "where does it go and how does it appear."
# ------------------------------------------------------------
func addMember(memberNode: Node) -> void:
	roster.append(memberNode)

	var rosterIndex = roster.size() - 1
	memberNode.memberNumber = rosterIndex

	var targetSlot = screenSlotFor(rosterIndex)

	# If the new member would land outside the visible window,
	# scroll just enough to bring it into view (specifically into
	# the fixed spotlight slot, so "arise" always happens under
	# the spotlight regardless of how deep the roster is).
	if targetSlot < 0 or targetSlot >= visibleSlotCount:
		scrollIndex = rosterIndex - spotlightSlot
		targetSlot = spotlightSlot

	memberNode.position.x = getSlotX(targetSlot)
	memberNode.position.y = baseY

	# Lock in the correct resting position for hover-in/out to return
	# to. Without this, PartyMember._ready() would have already captured
	# original_position as the scene's default (0,0)-ish spawn position,
	# captured BEFORE we ever placed it here — causing hover to snap it
	# back to the wrong spot.
	if "original_position" in memberNode:
		memberNode.original_position = memberNode.position

	repositionAll()

	if memberNode.has_method("arise"):
		memberNode.arise()


# ------------------------------------------------------------
# Forward/back scrolling, hooked up to your nav buttons.
# ------------------------------------------------------------
func scrollForward() -> void:
	var maxScroll = max(0, roster.size() - visibleSlotCount)

	scrollIndex = clamp(scrollIndex + 1, 0, maxScroll)
	repositionAll()


func scrollBackward() -> void:
	scrollIndex = clamp(
		scrollIndex - 1,
		0,
		max(0, roster.size() - visibleSlotCount)
	)

	repositionAll()


func canScrollForward() -> bool:
	return scrollIndex < max(0, roster.size() - visibleSlotCount)


func canScrollBackward() -> bool:
	return scrollIndex > 0


# ------------------------------------------------------------
# Updates the selection arrow states.
#
# The arrows remain visible at all times so the player can see
# what they are for, but they become disabled/gray when scrolling
# in that direction is impossible.
#
# Left arrow  = scroll forward
# Right arrow = scroll backward
# ------------------------------------------------------------
func updateSelectionArrowStates() -> void:
	var canMoveForward = canScrollForward()
	var canMoveBackward = canScrollBackward()

	leftArrow.disabled = !canMoveForward
	rightArrow.disabled = !canMoveBackward

	# White when usable, gray when disabled.
	if canMoveForward:
		leftArrow.modulate = Color.WHITE
	else:
		leftArrow.modulate = Color(0.5, 0.5, 0.5, 1.0)

	if canMoveBackward:
		rightArrow.modulate = Color.WHITE
	else:
		rightArrow.modulate = Color(0.5, 0.5, 0.5, 1.0)

	# Make sure a disabled button cannot retain keyboard focus.
	if leftArrow.disabled:
		leftArrow.release_focus()

	if rightArrow.disabled:
		rightArrow.release_focus()


# ------------------------------------------------------------
# Repositions every currently-visible roster member to their
# correct screen slot. Anything scrolled out of range is just
# left wherever it last was — it's off-screen anyway, and will
# get repositioned correctly the moment it scrolls back into view.
# ------------------------------------------------------------
func repositionAll() -> void:
	for i in range(roster.size()):
		var node = roster[i]

		if node == null:
			continue

		var slot = screenSlotFor(i)

		if slot >= 0 and slot < visibleSlotCount:
			node.position.x = getSlotX(slot)
			node.position.y = baseY

			if "original_position" in node:
				node.original_position = node.position

			node.visible = true
		else:
			node.visible = false

	updateSpotlightPosition()
	updateSelectionArrowStates()


# ------------------------------------------------------------
# Spotlight progresses 1, 2, 3, ... up to spotlightSlot as members
# are recruited, then freezes at spotlightSlot permanently once
# the roster grows past it (min() caps it there).
#
# Only X is touched — Y stays whatever was authored in the scene.
# ------------------------------------------------------------
func updateSpotlightPosition() -> void:
	if shopUI and shopUI.has_node("Spotlight"):
		var spotlight = shopUI.get_node("Spotlight")
		var newestMemberSlot = min(get_party_member_count(), spotlightSlot)

		spotlight.position.x = spotlightStartX + (newestMemberSlot * slotSpacing)


# ------------------------------------------------------------
# Lookups. Replaces the get_tree().get_nodes_in_group("PartyMember")
# scan in RecruitPartyMember's upgrade button handler.
# ------------------------------------------------------------
func get_member_by_number(num: int) -> Node:
	if num >= 0 and num < roster.size():
		return roster[num]

	return null


func get_party_member_count() -> int:
	return max(0, roster.size() - 1) # exclude the player slot


# ------------------------------------------------------------
# Navigation button callbacks.
#
# Left arrow = scroll forward
# Right arrow = scroll backward
# ------------------------------------------------------------
func _on_left_selection_arrow_button_down():
	scrollForward()


func _on_right_selection_arrow_button_down():
	scrollBackward()
