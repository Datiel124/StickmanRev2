extends Control

@onready var addr_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/AddrEntry
@onready var port_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/PortEntry
@onready var name_entry = $CanvasLayer/Menu/MarginContainer/VBoxContainer/HFlowContainer/NameEnt
var mp_peer := ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	addr_entry.text = Networking.ip
	port_entry.text = str(Netowrking.port)
	name_entry.text = Networking.player_name
	Global.notify_warn("Heads up, debug controls are disabled by default. Press F9 to enable them. Early alpha build right here.", 2, 5)
	name_entry.text = Global.generate_name()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_peer_connected.bind(-1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	$AudioStreamPlayer2D.play()
	await Fade.fade_out(0.3, Color(0,0,0,1),"Diagonal",false,true).finished
	await $AudioStreamPlayer2D.finished
	Global.is_multiplayer_game = false
	get_tree().change_scene_to_file("res://assets/scenes/debut/debug.tscn")
	Global.add_player()
	Fade.fade_in(0.3, Color(0,0,0,1),"GradientVertical",false,true)


func _on_host_btn_pressed():
	if port_entry.text and Global.validate_name(name_entry.text):
		$AudioStreamPlayer2D.play()
		%networkwait.visible = true
		create_server()


func _on_join_btn_pressed():
	if addr_entry.text and port_entry.text and Global.validate_name(name_entry.text):
		$AudioStreamPlayer2D.play()
		%networkwait.visible = true
		join_server()


func create_server():
	Networking.ip = addr_entry.text
	Netowrking.port = int(port_entry.text)
	Networking.player_name = name_entry.text
	Global.is_multiplayer_game = true
	mp_peer.create_server(Netowrking.port, 2)
	multiplayer.multiplayer_peer = mp_peer
	%networkwait.visible = true


func join_server():
	Networking.ip = addr_entry.text
	Netowrking.port = int(port_entry.text)
	Networking.player_name = name_entry.text
	Global.is_multiplayer_game = true
	mp_peer.create_client(Networking.ip, Netowrking.port)
	multiplayer.multiplayer_peer = mp_peer
	%networkwait.visible = true


func _on_peer_connected(id) -> void:
	#id is -1 if you just connected to server
	#change to lobby
	get_tree().change_scene_to_file("res://assets/scenes/menu/network_lobby.tscn")


func _on_cancelbutton_pressed() -> void:
	#cancel networking join/host
	%networkwait.visible = false
	multiplayer.multiplayer_peer.close()
	Global.is_multiplayer_game = false
	pass # Replace with function body.


func _on_randomize_name_pressed() -> void:
	name_entry.text = Global.generate_name()
	pass # Replace with function body.
