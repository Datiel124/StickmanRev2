extends Node

#MP Related
var port = 7777
var ip = "localhost"

var player_name = ""
#Dictionary of players
var peer_data = {}

signal peer_registered(id, data)
signal peer_unregistered(id)

#---------------------------#
# peer to peer architecture #
#---------------------------#

func _ready() -> void:
	multiplayer.peer_connected.connect(_a_peer_connected)
	multiplayer.peer_disconnected.connect(_a_peer_disconnected)
	multiplayer.connected_to_server.connect(_i_joined_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_server_disconnected():
	get_tree().paused = true
	await Fade.fade_out(0.2, Color.BLACK, "Diagonal", false, true).finished
	Global.notify_warn("Server disconnected.", 2, 8)
	get_tree().change_scene_to_file("res://assets/scenes/menu/menu.tscn")
	Fade.fade_in(0.2, Color.BLACK, "Diagonal", true, true).finished
	get_tree().paused = false


func _a_peer_connected(id) -> void:
	#i need their data so i can share it with the other players
	request_player_data.rpc_id(id)


func _i_joined_server() -> void:
	Global.notify_fade("Connected to server.")


@rpc("any_peer", "call_remote", "reliable", 1)
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


@rpc("any_peer", "call_remote", "reliable", 1)
func request_player_data() -> void:
	var id = multiplayer.get_remote_sender_id()
	send_player_data.rpc(get_my_data())


func get_peer_data(peer_id) -> Dictionary:
	return peer_data[peer_id]


func get_my_data() -> Dictionary:
	return {"player_name" = player_name}


signal peer_finish_task(id : int, task : String)
signal all_finished_task(task : String)
@rpc("any_peer", "call_remote", "reliable", 1)
func notify_finish_task(task : String = ""):
	#For some situations, we need to wait for all peers to be ready before continuing.
	#This function only really needs to inform the host, since peers shouldnt
	#be able to give eachother tasks.
	if multiplayer.is_server():
		peer_finish_task.emit(multiplayer.get_remote_sender_id(), task)


@rpc("authority", "call_remote", "reliable", 1)
func notify_all_finished_task(task : String = ""):
	if multiplayer.get_remote_sender_id() == 1:
		#extra security measure
		all_finished_task.emit(task)


var network_instance_count : int = 0

@rpc("authority", "reliable", "call_local", 1)
#server should increment this every time a node is instantiated
func increment_network_instance(count : int) -> void:
	network_instance_count = count + 1


@rpc("authority", "reliable", "call_local", 1)
func queue_free_node(node : Node) -> void:
	node.queue_free()


#other functions which are RPCed are intended to call this, it can't be called directly
func instance_node(count : int, node : PackedScene) -> Node:
	var new = node.instantiate()
	new.name += "_"+str(count)
	#increment counter as server
	if multiplayer.is_server():
		increment_network_instance.rpc(count)
	return new


func _a_peer_disconnected(id) -> void:
	Global.notify_fade(str("User %s (%s) left." % [peer_data[id].player_name, id]), 2, 2)
	peer_data.erase(id)
	peer_unregistered.emit(id)
