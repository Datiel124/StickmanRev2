extends Node3D

class_name Bullet

@export var bulletSpeed : float = 545
@export var bulletFlyDir : Vector3
@export var gravity = 9.8
@export var lifeTime = 4
@export var shooter : CharacterBody3D
var prevPos : Vector3 = Vector3()
var totalDist = 0

@export var useGravity = true

# Called when the node enters the scene tree for the first time.
func _ready():
	bulletFlyDir = global_transform.basis.z
	prevPos = global_transform.origin
	
	get_tree().create_timer(lifeTime).timeout.connect(delete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var newPos : Vector3 = global_transform.origin - (bulletFlyDir * bulletSpeed * delta)
	
	if useGravity:
		newPos.y -= 0.5 * gravity * delta * delta
		
	global_transform.origin = newPos
	
	prevPos = newPos

func delete():
	queue_free()
