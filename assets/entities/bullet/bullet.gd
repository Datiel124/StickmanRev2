extends Node3D

class_name Bullet

@export var bulletSpeed : float = 545
@export var bulletFlyDir : Vector3
@export var gravity = 9.8
@export var lifeTime = 4
@export var shooter : CharacterBody3D
var prevPos : Vector3 = Vector3()
var totalDist = 0
var isHit : bool = false
var newPos : Vector3

@export var useGravity = true

# Called when the node enters the scene tree for the first time.
func _ready():
	prevPos = global_transform.origin
	get_tree().create_timer(lifeTime).timeout.connect(delete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if !shooter == null:
		if shooter.is_controlled and !shooter.current_equipped == null:
			if shooter.pawn_cam.Aimcast.is_colliding():
				bulletFlyDir = shooter.pawn_cam.Aimcast.get_collision_point().normalized()
			else:
				bulletFlyDir = shooter.pawn_cam.getMidPoint(shooter.current_equipped.muzzle_point)
		else:
			bulletFlyDir = global_transform.basis.z
			
		
		newPos = global_transform.origin - (bulletFlyDir * bulletSpeed * delta)
		
	
	
	if useGravity:
		newPos.y -= 0.9 * gravity * delta * delta
		
	global_transform.origin = newPos
	
	
	##Cast the ray from prevpos to newpos
	var hitQuery = PhysicsRayQueryParameters3D.create(prevPos,newPos)
	
	if shooter:
		if isHit:
			hitQuery.exclude = [self]
		else:
			hitQuery.exclude = [shooter, self]
			
	var hitResult = get_world_3d().direct_space_state.intersect_ray(hitQuery)
	
	var dist = prevPos.distance_to(newPos)
	
	if hitResult:
		isHit = true
		newPos = hitResult.position
		if hitResult.collider.has_method("damage"):
			print("hit enemy")
			hitResult.collider.damage(shooter.current_equipped.Item_Resource.Damage, bulletFlyDir, hitResult.position)
			delete()
		


func delete():
	queue_free()
