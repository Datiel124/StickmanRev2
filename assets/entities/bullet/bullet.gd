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
var justCreated = true
@export var useGravity = true

# Called when the node enters the scene tree for the first time.
func _ready():
	prevPos = global_transform.origin
	get_tree().create_timer(lifeTime).timeout.connect(delete)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if justCreated:
		if !shooter == null:
			if !shooter.current_equipped == null:
				if shooter.get_owner().getMasterController().has_method("getKillcastPoint") and shooter.get_owner().getMasterController().checkIfKillcastColliding() == true:
					bulletFlyDir = (global_transform.origin - shooter.get_owner().getMasterController().getKillcastPoint()).normalized()
				else:
					bulletFlyDir = global_transform.basis.z
		else:
			bulletFlyDir = global_transform.basis.z
		
		
		##Cast the ray from prevpos to newpos
		var hitQuery
		if !shooter.get_owner().getMasterController().has_method("getKillcastPoint"):
			hitQuery = PhysicsRayQueryParameters3D.create(prevPos,newPos)
			
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
					hitResult.collider.damage(shooter.current_equipped.Item_Resource.Damage, shooter.current_equipped.Item_Resource.physicsPushMult,  bulletFlyDir, hitResult.position, true, shooter.current_equipped.Item_Resource.knockbackForce)
					#delete()
				
		else:
			if shooter.get_owner().getMasterController().has_method("getKillcastPoint") and shooter.get_owner().getMasterController().checkIfKillcastColliding() == true:
				var hitPosition = shooter.get_owner().getMasterController().getKillcastPoint()
				var hitResult = shooter.get_owner().getMasterController().getKillcastCollider()
				if hitResult.has_method("damage"):
					hitResult.damage(shooter.current_equipped.Item_Resource.Damage, shooter.current_equipped.Item_Resource.physicsPushMult, bulletFlyDir, hitPosition, true, shooter.current_equipped.Item_Resource.knockbackForce)
					delete()
				
		justCreated = false
			
	newPos = global_transform.origin - (bulletFlyDir * bulletSpeed * delta)

	if useGravity:
		newPos.y -= 0.9 * gravity * delta * delta

	global_transform.origin = newPos


func delete():
	queue_free()
