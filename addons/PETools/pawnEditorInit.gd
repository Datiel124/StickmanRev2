@tool
extends EditorPlugin
##Trigger Editor Variable Initializer
const triggerEditorScene := preload("res://addons/PETools/triggerEditor/triggerEditor.tscn")
const triggerEditorScript := preload("res://addons/PETools/triggerEditor/triggerEditor.gd")
var triggerUI : triggerEditorScript

func _enter_tree():
	##Init Trigger Editor
	triggerUI = triggerEditorScene.instantiate() as Control
	add_control_to_bottom_panel(triggerUI, "Trigger Editor")
	pass


func _exit_tree():
	##Remove Trigger Editor
	remove_control_from_bottom_panel(triggerUI)
	triggerUI.free()
	pass
