extends CharacterBody3D

class_name Pawn
var ragdoll = preload("res://assets/entities/pawn/pawn_ragdoll.tscn")

@onready var CameraPosNode = $CameraPos
@onready var ik_node = $Mesh/Male/MaleSkeleton/Skeleton3D/SkeletonIK3D
@onready var ik_marker = $Mesh/Lookat
@onready var pawn_skeleton = $Mesh/Male/MaleSkeleton/Skeleton3D
@onready var anim_player = $Mesh/AnimationPlayer
@onready var weapon_lower_timer = $weapon_lower_timer
#@onready var Camera_spring = $CameraPos/horizontal/vertical/SpringArm3D

@export var pawn_cam : CharacterBody3D
@export var is_controlled = false
@export var Health = 100
@export var is_dead = false
@export var is_aiming = false

@export var character_speed = 5.0
@export var jump_force = 4.5


@export var acceleration = 3

@export var rot = 0.0
var turn_rate = 11
var default_turn_rate = 11

#Camera Data
@export var CameraResource : CameraData

## Camera shoulder position, 0 = Right, 1 = left
@export var camera_shoulder = 0

#Weapon Related
@export var has_weapon_equipped = false

#Animation Related
@onready var anim_tree = $Mesh/AnimationTree

##Character Related
var c_name = ""

##MP Related
var mp_id:int 

#Movement Variables
var MoveLeft = 0.0
var MoveRight = 0.0
var MoveForward = 0.0
var MoveBackwards = 0.0

#Inventory and Equip
@export var inv_items = Inventory.size() - 1
@export var Inventory:Array
@onready var itemholder = $R_Holder
var current_equipped = null
var current_equipped_index = 0

var last_bone_hit = 0
var last_impulse = Vector3(8, 0 , 0)
var impulse_amnt = 9

var created_ragdoll
var is_using:bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	if Global.is_multiplayer_game:
		set_multiplayer_authority(str(name).to_int())

func _ready():
	Inventory.append(null)

func _physics_process(delta):
	if Global.is_multiplayer_game:
		if not is_multiplayer_authority(): return
	
	if Health <= 0 and !is_dead:
		kill(last_bone_hit)
		#velocity = Vector3(0,0,0)
		
		if is_controlled:
			change_to_dead_cam()
	
	if is_controlled:
		
		if Global.is_multiplayer_game:
			if not is_multiplayer_authority(): return
		
		if Input.is_action_pressed("Aim"):
			if !is_using:
				is_aiming = true
			is_using = false
			pawn_cam.fov_zoom(pawn_cam.default_cam_fov - 25, delta)
		else:
			pawn_cam.fov_zoom(pawn_cam.default_cam_fov, delta)

		if !Input.is_action_pressed("Aim"):
			if !is_using:
				is_aiming = false
			
		
		if Input.is_action_pressed("Shoot"):
			if !current_equipped == null:
				current_equipped.use()
				
		
		if Input.is_action_just_released("mwheel_up"):
			if !current_equipped_index > Inventory.size():
				current_equipped_index = current_equipped_index + 1
				
		if Input.is_action_just_released("mwheel_down"):
			if !current_equipped_index < 0:
				current_equipped_index = current_equipped_index - 1
		
		MoveLeft = Input.get_action_strength("MoveLeft")
		MoveRight = Input.get_action_strength("MoveRight")
		MoveForward = Input.get_action_strength("MoveForward")
		MoveBackwards = Input.get_action_strength("MoveBackwards")
		
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, rot, delta * turn_rate)
		
		#Set Rotation vector to Camera pos
		rot = pawn_cam.rot
		


			
		#Swap Shoulder
		if Input.is_action_just_pressed("swap_shoulder"):
			swap_shoulder()
			
	# Add the gravity.
	if !is_dead:
		if not is_on_floor():
			velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = jump_force

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Vector3(MoveRight - MoveLeft, 0, MoveBackwards - MoveForward).rotated(Vector3.UP, rot)
		
		if direction != Vector3.ZERO:
				direction = direction.normalized()
		
		velocity.x = lerp(velocity.x, direction.x * character_speed, delta * acceleration )
		velocity.z = lerp(velocity.z, direction.z * character_speed, delta * acceleration )
	
	anim_tree.set("parameters/Walk/blend_position",Vector2(velocity.x, velocity.z).rotated(rot))
	
	
	
	move_and_slide()
	
	#Aim Lerp
	if is_aiming:
		ik_node.start()
		ik_node.interpolation = lerpf(ik_node.get_interpolation(), 1, 10 * delta)
		if is_controlled:
			turn_rate = 25
			ik_marker.rotation.x = -pawn_cam.vert.rotation.x
	else:
		turn_rate = default_turn_rate
		ik_node.interpolation = lerpf(ik_node.get_interpolation(), 0, 10 * delta)
		if ik_node.interpolation <= 0:
			ik_node.stop()
	
	#Inventory and Item equip start
	inv_items = Inventory.size() - 1
	if !current_equipped_index > inv_items:
		if current_equipped_index == 0:
			has_weapon_equipped = false
			current_equipped = Inventory[current_equipped_index]
			for item in itemholder.get_child_count():
				itemholder.get_child(item).visible = false
		else:
			if !Inventory[current_equipped_index] == null:
				has_weapon_equipped = true
				Inventory[current_equipped_index].show()
				for item in itemholder.get_child_count():
					if !itemholder.get_child(item) == current_equipped:
						itemholder.get_child(item).hide()
		
		if has_weapon_equipped:
			current_equipped = Inventory[current_equipped_index]
		
	if current_equipped_index > inv_items or current_equipped_index <= -1:
		current_equipped_index = 0
	
	## Weapon Animation
	if !current_equipped == null:
		anim_tree.set("parameters/weapon_blend/blend_amount", lerpf(anim_tree.get("parameters/weapon_blend/blend_amount"), 1, 15 * delta))
		
		if current_equipped.Item_Resource.animation_type == 0:
			anim_tree.set("parameters/weapon_type/transition_request", "pistol_baretta")
			if is_aiming == false:
				anim_tree.set("parameters/pistol_baretta_idleaim/blend_position", lerpf(anim_tree.get("parameters/pistol_baretta_idleaim/blend_position"), 0, 15 * delta))
			else:
				anim_tree.set("parameters/pistol_baretta_idleaim/blend_position", lerpf(anim_tree.get("parameters/pistol_baretta_idleaim/blend_position"), 1, 35 * delta))
			
		if current_equipped.Item_Resource.animation_type == 1:
			anim_tree.set("parameters/weapon_type/transition_request", "honeybadger")
			if !is_aiming:
				anim_tree.set('parameters/honeybadger_idle_aim/blend_position', lerpf(anim_tree.get('parameters/honeybadger_idle_aim/blend_position'), 0, 15 * delta))
			else:
				anim_tree.set('parameters/honeybadger_idle_aim/blend_position', lerpf(anim_tree.get('parameters/honeybadger_idle_aim/blend_position'), 1, 35 * delta))
	else:
		anim_tree.set("parameters/weapon_blend/blend_amount", lerpf(anim_tree.get("parameters/weapon_blend/blend_amount"), 0, 15 * delta))
		is_using = false
			
	if is_using == true:
		is_aiming = true


func swap_shoulder():
	if camera_shoulder == 0:
		camera_shoulder = 1
	else:
		camera_shoulder = 0

func pawn_animation(delta):
	pass

func summon_item(item):
	if !itemholder.has_node(str(item)):
		var spawned = item.instantiate()
		spawned.holder = self
		spawned.is_held = true
		itemholder.add_child(spawned)
		Inventory.append(spawned)
		if !spawned.is_held:
			spawned.is_held = true
	pass

func kill(bone_hit):
	$Collider.disabled = true
	is_dead = true
	Health = 0
	create_ragdoll(bone_hit)
	anim_tree.active = false
	hide()
	
func create_ragdoll(impulse_bone:int = 0):
	var _ragdoll = ragdoll.instantiate()
	_ragdoll.global_transform = $Mesh.global_transform
	get_tree().root.get_node("World").add_child(_ragdoll)
	for bones in _ragdoll.ragdoll_skeleton.get_bone_count():
		_ragdoll.ragdoll_skeleton.set_bone_pose_rotation(bones, $Mesh/Male/MaleSkeleton/Skeleton3D.get_bone_pose_rotation(bones))
		_ragdoll.ragdoll_skeleton.set_bone_pose_position(bones, $Mesh/Male/MaleSkeleton/Skeleton3D.get_bone_pose_position(bones))
		
	for bone in _ragdoll.ragdoll_skeleton.get_child_count():
		var child = _ragdoll.ragdoll_skeleton.get_child(bone)
		if child is PhysicalBone3D:
			if child.get_bone_id() == impulse_bone:
				_ragdoll.ragdoll_skeleton.physical_bones_start_simulation()
				child.apply_central_impulse(last_impulse)
	
	_ragdoll.target_skeleton = pawn_skeleton
	_ragdoll.bone_hit = last_bone_hit
	_ragdoll.pawn_to_animate = self
	_ragdoll.pawn_dead = get_parent()
	created_ragdoll = ragdoll


func _on_weapon_lower_timer_timeout():
	is_using = false
	is_aiming = false

func change_to_dead_cam():
	CameraPosNode.remove_child(pawn_cam)
	created_ragdoll.add_child(pawn_cam)

func damage(amount:int):
	Health = Health - amount
	
