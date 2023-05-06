extends Node3D

class_name Pawn_Controller

@onready var deleteTimer = $Timer
@onready var character_pawn = $character_pawn
## What controls this pawn? A pawn master controller will drive this character. AI or Player input.
@export var controllerScript : masterController


func setMasterController(mcontroller):
	controllerScript = mcontroller
	mcontroller.pawn = character_pawn


func getMasterController() -> masterController:
	return controllerScript


func clearMasterController():
	controllerScript = null
	for child in character_pawn.get_children():
		if child is masterController:
			child.queue_free()




func _on_timer_timeout():
	queue_free()
