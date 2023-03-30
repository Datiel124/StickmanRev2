extends Control

@onready var addr_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/AddrEntry
@onready var port_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/PortEntry
@onready var name_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/NameEnt
var mp_peer = ENetMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	addr_entry.text = Global.ip
	port_entry.text = str(Global.port)
	name_entry.text = Global.player_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	Global.is_multiplayer_game = false
	get_tree().change_scene_to_file("res://assets/scenes/debut/debug.tscn")
	Global.add_player(multiplayer.get_unique_id(), Vector3(0,0,0))

func _on_host_btn_pressed():
	if addr_entry.text and port_entry.text and name_entry.text != "":
		Global.port = int(str(port_entry.text))
		create_server()

func _on_join_btn_pressed():
	if addr_entry.text and port_entry.text and name_entry.text != "":
		join_server()
		print("Connecting to " + str(Global.ip) + ", Port: " + str(Global.port))
		


func create_server():
	Global.ip = addr_entry.text
	Global.port = int(port_entry.text)
	Global.player_name = name_entry.text
	Global.is_multiplayer_game = true
	mp_peer.create_server(Global.port)
	multiplayer.multiplayer_peer = mp_peer
	get_tree().change_scene_to_file("res://assets/scenes/debut/debug.tscn")
	Global.add_player(multiplayer.get_unique_id(), Vector3(0,0,0))
	multiplayer.peer_connected.connect(Global.add_player)

func join_server():
	Global.ip = addr_entry.text
	Global.port = int(port_entry.text)
	Global.player_name = name_entry.text
	Global.is_multiplayer_game = true
	get_tree().change_scene_to_file("res://assets/scenes/debut/debug.tscn")
	mp_peer.create_client(Global.ip, Global.port)
	multiplayer.multiplayer_peer = mp_peer
