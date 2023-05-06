extends Node3D
##What trigger will this activate
@export var trigger : Trigger
var pawnActivated : bool = false
var isExectuting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func execute_trigger():
	pass

func _on_area_3d_area_entered(area):
	#print("entered trigger")
	pass
