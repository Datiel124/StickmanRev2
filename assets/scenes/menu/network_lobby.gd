extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_list(str(multiplayer.get_unique_id()) + " (you)")
	for peer in multiplayer.get_peers():
		add_to_list(peer)
	pass # Replace with function body.


func add_to_list(theirname) -> Control:
	var new = $placeholder.duplicate()
	$ScrollContainer/VBoxContainer.add_child(new)
	new.get_node("Label").text = str(theirname)
	new.visible = true
	return new
