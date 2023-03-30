extends Node

@onready var blood_spurt = preload("res://assets/particles/blood/blood_spurt.tscn")
@onready var bullet_tracer = preload("res://assets/particles/bullet/bullet_tracer/bull_trace.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func create_blood(type:int, pos:Vector3):
	var blood_to_spawn
	
	##Type 0 = Spurt
	if type == 0:
		blood_to_spawn = blood_spurt.instantiate()
		add_child(blood_to_spawn)
		blood_to_spawn.position = pos


func create_bullet_tracer(pos:Vector3, rot:Vector3, parent):
	var created_b_tracer = bullet_tracer.instantiate()
	#created_b_tracer.position = pos
	#created_b_tracer.rotation = rot
	parent.add_child(created_b_tracer)
	
