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


func _a_peer_connected(id) -> void:
	print("peer %s connected" % [id])
	request_player_data.rpc_id(id)


func _i_joined_server() -> void:
	send_player_data.rpc(get_my_data())


@rpc("any_peer", "call_remote", "reliable")
func send_player_data(data) -> void:
	#Recieving data from new peer
	var id = multiplayer.get_remote_sender_id()
	data["id"] = id
	print("recieved data %s from peer %s" % [data, id])
	peer_data[id] = data
	peer_registered.emit(id, data)


@rpc("any_peer", "call_remote", "reliable")
func request_player_data() -> void:
	var id = multiplayer.get_remote_sender_id()
	send_player_data.rpc_id(id, get_my_data())


func get_peer_data(peer_id) -> Dictionary:
	return peer_data[peer_id]


func get_my_data() -> Dictionary:
	return {"player_name" = player_name}


func _a_peer_disconnected(id) -> void:
	peer_data.erase(id)
	peer_unregistered.emit(id)
