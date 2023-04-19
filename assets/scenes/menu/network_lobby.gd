extends Control


@onready var settings = $Settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_peer_list()
	setup_host_only()
	Networking.peer_registered.connect(refresh_peer_list.unbind(2))
	Networking.peer_unregistered.connect(refresh_peer_list.unbind(1))
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup_host_only() -> void:
	%StartButton.disabled = !multiplayer.is_server()
	%SettingsButton.disabled = !multiplayer.is_server()


func add_to_list(theirname) -> Control:
	var new = $placeholder.duplicate()
	%PlayerList.add_child(new)
	new.get_node("Label").text = str(theirname)
	new.visible = true
	return new


func refresh_peer_list() -> void:
	print("Refreshing peer list...")
	for old in %PlayerList.get_children():
		old.queue_free()

	add_to_list("(you) " + Networking.player_name + " ("+(str(multiplayer.get_unique_id()) if multiplayer.get_unique_id() != 1 else "HOST")+")")
	for peer in Networking.peer_data:
		var theirdata = Networking.peer_data[peer]
		add_to_list(theirdata.player_name + " (" + (str(theirdata.id) if theirdata.id != 1 else "HOST") + ")")


var peers_finished_with_task = []
func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		start_game.rpc(settings.selected_level)
	else:
		#lol you arent server! DIE
		get_tree().quit()

	#load stuff just as peers have to
	get_tree().paused = true
	var task = "start_the_game"
	var level : PackedScene = load(settings.selected_level)
	Global.notify_fade("Starting the game.", 1, 1)

	Networking.peer_finish_task.connect(func _on_peer_finish_task(id, _task):
		if _task == task and !peers_finished_with_task.has(id):
			Global.notify_fade(str("%s finished loading." % [Networking.get_peer_data(id).player_name]), 1, 1)
			peers_finished_with_task.append(_task)
		)

	while peers_finished_with_task.size() < multiplayer.get_peers().size():
		await get_tree().process_frame

	Networking.notify_all_finished_task.rpc(task)
	finalize_load(level)


@rpc("authority", "call_remote", "reliable")
func start_game(level_path : String) -> void:
	#load level at the path
	#PAUSE TREE!!!
	Global.notify_fade("Host starting game...", 1, 1)
	get_tree().paused = true
	if $NetworkLobby/slowpc.button_pressed:
		await get_tree().create_timer(randf_range(3, 20)).timeout
	var level : PackedScene = load(level_path)
	Global.notify_fade("Ready! Waiting for peers...", 1, 1)
	Networking.notify_finish_task.rpc_id(1, "start_the_game")
	#wait for everyone else

	var waitforthem
	while waitforthem != "start_the_game":
		waitforthem = await Networking.all_finished_task

	finalize_load(level)


func finalize_load(loaded_level) -> void:
	Global.notify_fade("Everyone finished loading, starting...", 1, 1)
	get_tree().paused = false
	get_tree().change_scene_to_packed(loaded_level)
	#add myself
	#The position these are initially spawned in doesn't really matter, because they will be synced.
	Global.add_player(Vector3.ZERO, multiplayer.get_unique_id())
	#add everyone else
	for i in multiplayer.get_peers():
		Global.add_player(Vector3.ZERO, i)


func _on_settings_button_pressed() -> void:
	$Settings.visible = true
	pass
