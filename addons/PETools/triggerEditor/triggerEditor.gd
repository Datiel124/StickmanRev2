@tool
extends Control
@onready var graph = $triggerGraph
var plugin : EditorPlugin
var selectedTrigger = 0
var triggers = [
	load("res://addons/PETools/triggerEditor/triggers/playerPawnEnter.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/debugText.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_node_add_item_selected(index):
	selectedTrigger = index


func _on_add_node_pressed():
	var triggerSpawn = triggers[selectedTrigger].instantiate()
	graph.add_child(triggerSpawn)


func _on_trigger_graph_connection_request(from_node, from_port, to_node, to_port):
	graph.connect_node(from_node, from_port, to_node, to_port)
