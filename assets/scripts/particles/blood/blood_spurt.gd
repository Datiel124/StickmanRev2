extends Node3D
@onready var blood_effect = $blood

var blood_amount = randi_range(45,155)


# Called when the node enters the scene tree for the first time.
func _ready():
	blood_effect.amount = blood_amount
	blood_effect.one_shot = true
	blood_effect.emitting = true

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
