extends Node2D

@onready var currentSong = $CurrentSong

@onready var song1 = preload("res://Audio/Music/Doodad.mp3")
@onready var song2 = preload("res://Audio/Music/KirbySaveRoomTypeBeat.mp3")
@onready var song3 = preload("res://Audio/Music/SheTookMyTitleScreen.mp3")

@onready var playlist = [song1, song2, song3]
var rng = 0

func _ready():
	playSong()
	
func playSong():
	rng = randi_range(0, len(playlist) - 1)
	currentSong.stream = playlist[rng]
	currentSong.play()

func _on_current_song_finished():
	playSong()
