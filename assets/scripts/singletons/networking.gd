extends Node

#MP Related
var port = 7777
var ip = "localhost"

var player_name = ""
#Dictionary of players
var peer_data = {}

signal peer_registered(id, data)
signal peer_unregistered(id)

#############################
# peer to peer architecture #
#############################

func _ready() -> void:
	multiplayer.peer_connected.connect(_a_peer_connected)
	multiplayer.peer_disconnected.connect(_a_peer_disconnected)
	multiplayer.connected_to_server.connect(_i_joined_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_server_disconnected():
	await Fade.fade_out(0.3, Color.BLACK, "Diagonal", false, true).finished
	Global.notify_warn("Error - Server disconnected.")
	get_tree().change_scene_to_file("res://assets/scenes/menu/menu.tscn")
	Fade.fade_in(0.3, Color.BLACK, "Diagonal", true, true).finished


func _a_peer_connected(id) -> void:
	#i need their data so i can share it with the other players
	request_player_data.rpc_id(id)


func _i_joined_server() -> void:
	Global.notify_fade("Connected to server.")


@rpc("any_peer", "call_remote", "reliable")
func send_player_data(data) -> void:
	#Recieving data from new peer
	#TODO for some reason, clients recieve this twice from the server
	#figure out why that happens- could be an issue later on
	var id = multiplayer.get_remote_sender_id()

	if peer_data.has(id):
		#don't register if already exists
		return

	data["id"] = id
	peer_data[id] = data
	Global.notify_fade(str("User %s (%s) registered." % [data.player_name, id]), 2, 5)
	peer_registered.emit(id, data)


@rpc("any_peer", "call_remote", "reliable")
func request_player_data() -> void:
	var id = multiplayer.get_remote_sender_id()
	send_player_data.rpc(get_my_data())


func get_peer_data(peer_id) -> Dictionary:
	return peer_data[peer_id]


func get_my_data() -> Dictionary:
	return {"player_name" = player_name}


func _a_peer_disconnected(id) -> void:
	Global.notify_fade(str("User %s (%s) left." % [peer_data[id].player_name, id]), 2, 2)
	peer_data.erase(id)
	peer_unregistered.emit(id)
