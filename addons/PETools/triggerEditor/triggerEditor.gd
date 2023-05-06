@tool
extends Control
@onready var graph = $triggerGraph
var plugin : EditorPlugin
var saveDir 
var selectedTrigger = 0
var triggers = [
	load("res://addons/PETools/triggerEditor/triggers/PawnEnter.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/PawnLeave.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/waitTrigger.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/waitTrigger.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/gotoSceneTrigger.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/debugText.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/debugText.tscn"),
	load("res://addons/PETools/triggerEditor/triggers/debugTextWarn.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$FileDialog.current_dir = "res://assets/resources/triggers"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_node_add_item_selected(index):
	selectedTrigger = index
	print(selectedTrigger)


func _on_add_node_pressed():
	var triggerSpawn = triggers[selectedTrigger].instantiate()
	graph.add_child(triggerSpawn)


func _on_trigger_graph_connection_request(from_node, from_port, to_node, to_port):
	graph.connect_node(from_node, from_port, to_node, to_port)


func _on_save_triggers_pressed():
	$FileDialog.file_mode = 4
	$FileDialog.popup_centered()

func _on_load_triggers_pressed():
	$FileDialog.file_mode = 0
	$FileDialog.popup_centered()


func _on_trigger_graph_disconnection_request(from_node, from_port, to_node, to_port):
	graph.disconnect_node(from_node, from_port, to_node, to_port)


func _on_file_dialog_canceled():
	$FileDialog.hide()


func _on_file_dialog_file_selected(path):
	if $FileDialog.file_mode == 4:
		var triggerContent = getTriggerContent()
		saveTrigger(triggerContent, path)


func _on_file_dialog_dir_selected(dir):
	if $FileDialog.file_mode == 4:
		saveDir = dir

func saveTrigger(triggerContent, path):
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_csv_line(triggerContent)

func getTriggerContent():
	var content = graph.get_connection_list()
	return content
