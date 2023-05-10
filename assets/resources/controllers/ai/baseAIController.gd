extends masterController
class_name AIController

var aiMoveTime :bool = false
##Onready Set
@onready var randomRefresh = $randomRefresh
@onready var navPointGrabber = $navPointGrabber
@onready var navAgent : NavigationAgent3D = $NavigationAgent3D
@onready var moveTo = $moveTo

##Pathfinding
var currLocation:Vector3 
var newVelocity:Vector3 

##Current attached pawn
var pawn : Pawn

# Called when the node enters the scene tree for the first time.
func _ready():
	if !pawn == null:
		pawn.rot = pawn.pawnMesh.global_transform.basis.get_euler().y
		pawn.character_speed = pawn.defaultCharacterSpeed - randf_range(0.2,0.6)
		updateTargetLocation(getNavPoints(true).global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !pawn == null:
		pawn.rot = pawn.pawnMesh.global_transform.basis.get_euler().y
		if aiMoveTime:
			if navAgent.is_target_reachable():
				var nextLocation = navAgent.get_next_path_position()
				currLocation = pawn.global_position
				newVelocity = (nextLocation - currLocation).normalized() * pawn.character_speed
				navAgent.set_velocity(newVelocity)
				pawn.pawnMesh.rotation.y = lerp_angle(pawn.pawnMesh.rotation.y, atan2(-pawn.direction.x,-pawn.direction.z), delta * 3)
			else:
				aiMoveTime = false
				updateTargetLocation(getNavPoints(true).global_position)
		
func updateTargetLocation(targetPosition:Vector3):
	moveTo.global_position = targetPosition
	navAgent.set_target_position(moveTo.global_position)
	navAgent.target_desired_distance = randf_range(2,5)
	aiMoveTime = true

func getNavPoints(getRandomPoint:bool=false):
	if getRandomPoint == false:
		for navPoints in navPointGrabber.get_overlapping_bodies():
			if navPoints is Marker3D:
				return navPoints
	else:
		var navPointArray = Global.world.worldWaypoints.get_children()
		for navPoint in navPointArray:
			var randomPoint = navPointArray.pick_random()
			return randomPoint

func _on_random_refresh_timeout():
	updateTargetLocation(getNavPoints(true).global_position)
	randomRefresh.wait_time = randf_range(0.5,5)
	$randomRefresh.stop()

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	pawn.direction = pawn.direction.move_toward(safe_velocity, 0.25)

func _on_navigation_agent_3d_target_reached():
	pawn.direction = Vector3.ZERO
	aiMoveTime = false
	$randomRefresh.start()
	pawn.character_speed = pawn.defaultCharacterSpeed - randf_range(0.2,0.6)

