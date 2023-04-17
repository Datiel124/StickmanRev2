extends Node

#MP Related
var port = 7777
var ip = "localhost"

var player_name = ""
#Dictionary of players
var player_data = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(id) -> void:
	pass


func _on_peer_disconnected(id) -> void:
