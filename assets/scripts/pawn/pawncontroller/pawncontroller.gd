extends Node3D

class_name Pawn_Controller

@onready var character_pawn = $character_pawn
var controllerScript


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setMasterController(controller):
	controllerScript = controller
	
func getMasterController():
	return controllerScript
	
func clearMasterController():
	controllerScript = null
