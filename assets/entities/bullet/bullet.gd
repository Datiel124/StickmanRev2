extends Node3D

class_name Bullet

@export var bulletSpeed : float = 545
@export var bulletFlyDir : Vector3
@export var gravity = 9.8
@export var lifeTime = 4
@export var shooter : CharacterBody3D
@export var explosion : PackedScene
@export var explode_on_timeout : bool = false
var prevPos : Vector3 = Vector3()
var totalDist = 0
var isHit : bool = false
var newPos : Vector3
var justCreated = true
@export var useGravity = true

# Called when the node enters the scene tree for the first time.
func _ready():
	prevPos = global_transform.origin


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
		var hitQuery : PhysicsRayQueryParameters3D
		hitQuery = PhysicsRayQueryParameters3D.create(prevPos,newPos)
		var hitResult = get_world_3d().direct_space_state.intersect_ray(hitQuery)
		if !shooter.get_owner().getMasterController().has_method("getKillcastPoint"):
			if shooter:
				if isHit:
					hitQuery.exclude = [self]
				else:
					hitQuery.exclude = [shooter, self]
			var dist = prevPos.distance_to(newPos)

			if hitResult:
				print("Hit target!!!")
				isHit = true
				newPos = hitResult.position
				if hitResult.collider.has_method("damage"):
					hitResult.collider.damage(shooter.current_equipped.Item_Resource.Damage, shooter.current_equipped.Item_Resource.physicsPushMult,  bulletFlyDir, hitResult.position, true, shooter.current_equipped.Item_Resource.knockbackForce)
					#delete()

		else:
			if shooter.get_owner().getMasterController().has_method("getKillcastPoint") and shooter.get_owner().getMasterController().checkIfKillcastColliding() == true:
				var hitPosition = shooter.get_owner().getMasterController().getKillcastPoint()
				var hitNormal = shooter.get_owner().getMasterController().getKillcastNormal()
				hitResult = shooter.get_owner().getMasterController().getKillcastCollider()
				Global.detect_surface(hitResult, hitPosition, hitNormal)
				if hitResult.has_method("damage"):
					hitResult.damage(shooter.current_equipped.Item_Resource.Damage, shooter.current_equipped.Item_Resource.physicsPushMult, bulletFlyDir, hitPosition, true, shooter.current_equipped.Item_Resource.knockbackForce)
					#explode(hitResult.global_position)

		justCreated = false

	newPos = global_transform.origin - (bulletFlyDir * bulletSpeed * delta)

	if useGravity:
		newPos.y -= 0.9 * gravity * delta * delta

	global_transform.origin = newPos



var pos_prev_frame : Vector3
func _process(delta: float) -> void:
	scale.z = global_position.distance_to(prevPos) * 0.8
	look_at(prevPos, Vector3.BACK)
	pos_prev_frame = global_position


func explode(atPosition):
	var new = explosion.instantiate() as Node3D
	new.top_level = true
	#HACK - add to level instead
	Global.world.worldMisc.add_child(new)
	new.global_position = atPosition
	delete()


func delete():
	queue_free()


func _on_timer_timeout():
	delete()
