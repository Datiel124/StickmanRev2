extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_peer_list()
	Networking.peer_registered.connect(refresh_peer_list.unbind(2))
	Networking.peer_unregistered.connect(refresh_peer_list.unbind(1))


func add_to_list(theirname) -> Control:
	var new = $placeholder.duplicate()
	$ScrollContainer/VBoxContainer.add_child(new)
	new.get_node("Label").text = str(theirname)
	new.visible = true
	return new


func refresh_peer_list() -> void:
	print("Refreshing peer list...")
	for old in $ScrollContainer/VBoxContainer.get_children():
		old.queue_free()

	add_to_list("(you) " + Networking.player_name + " ("+str(multiplayer.get_unique_id())+")")
	for peer in Networking.peer_data:
		var theirdata = Networking.peer_data[peer]
		add_to_list(theirdata.player_name + " (" + str(theirdata.id) + ")")
