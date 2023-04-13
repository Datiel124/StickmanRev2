extends Node3D

class_name Pawn_Controller

@onready var character_pawn = $character_pawn
## What controls this pawn? A pawn master controller will drive this character. AI or Player input.
@export var controllerScript : masterController


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setMasterController(mcontroller):
	controllerScript = mcontroller
	
func getMasterController():
	return controllerScript
	
func clearMasterController():
	controllerScript = null
	for child in get_children():
		if child is masterController:
			child.queue_free()
