extends CharacterBody3D

class_name Pawn
var ragdoll = preload("res://assets/entities/pawn/pawn_ragdoll.tscn")

var dt
signal pickedupItem

@onready var equipsounds = $equipsounds
@onready var CameraPosNode = $CameraPos
@onready var ik_node = $Mesh/Male/MaleSkeleton/Skeleton3D/SkeletonIK3D
@onready var ik_marker = $Mesh/Lookat
@onready var pawn_skeleton = $Mesh/Male/MaleSkeleton/Skeleton3D
@onready var anim_player = $Mesh/AnimationPlayer
@onready var weapon_lower_timer = $weapon_lower_timer
@onready var hitBoxes = $Mesh/Male/MaleSkeleton/Hitboxes
@onready var pawnMesh = $Mesh
@onready var pawnBody = $Mesh/Male/MaleSkeleton/Skeleton3D/MaleBody
@onready var pawnHead = $Mesh/Male/MaleSkeleton/Skeleton3D/MaleHead
@onready var anim_tree = $Mesh/AnimationTree
@onready var nametag = %nametag

@export var step_height: float = 0.25
@export var pawnController : masterController
@export var Health = 100
@export var is_dead = false
@export var is_aiming = false

@export var defaultCharacterSpeed = 3.0
@export var character_speed = 3.0
@export var jump_force = 4.5


@export var acceleration = 3

@export var rot = 0.0
var pawnMat
@export var pawnColor : Color = Color(1,0.425, 0, 255):
	set(value):
		pawnColor = value
		var material = load("res://assets/materials/pawn/pawn_dev/pawn_tex.tres").duplicate()
		material.resource_local_to_scene = true
		material.albedo_color = value
		pawnMat = material
		pawnBody.get_active_material(0).resource_local_to_scene = true
		pawnHead.get_active_material(0).resource_local_to_scene = true
		pawnBody.set_surface_override_material(0, material)
		pawnHead.set_surface_override_material(0, material)


#Weapon Related
@export var has_weapon_equipped = false

##If gun is blocked by being inside a wall or something
var isItemBlocked:bool = false:
	set(value):
		isItemBlocked = value

##Character Related
var c_name = ""

##MP Related
var mp_id:int

#Movement Variables
var direction : Vector3
var MoveLeft = 0.0
var MoveRight = 0.0
var MoveForward = 0.0
var MoveBackwards = 0.0

#Inventory and Equip
signal item_changed
@export var Inventory: Array
@onready var itemholder = $R_Holder
var current_equipped = null
var current_equipped_index := 0:
	set(value):
		current_equipped_index = clamp(value, 0, Inventory.size()-1)
		emit_signal("item_changed")

var last_bone_hit = 0
var last_impulse: Vector3
var impulse_amnt = 9
var impulseDir :Vector3

var created_ragdoll
var is_using:bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Inventory.append(null)
#	nametag.visible = !is_multiplayer_authority() and multiplayer.multiplayer_peer != null


func _physics_process(delta):
#	if multiplayer.multiplayer_peer != null:
#		if not is_multiplayer_authority(): return

	if Health <= 0 and !is_dead:
		kill(last_bone_hit)
		#velocity = Vector3(0,0,0)

	# Add the gravity.
	if !is_dead:
		if not is_on_floor():
			velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = jump_force

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.

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
	else:
		ik_node.interpolation = lerpf(ik_node.get_interpolation(), 0, 10 * delta)
		if ik_node.interpolation <= 0:
			ik_node.stop()

	#Inventory and Item equip start
	if current_equipped_index == 0:
		has_weapon_equipped = false
		current_equipped = null
		for item in itemholder.get_child_count():
			itemholder.get_child(item).visible = false
	else:
		if Inventory[current_equipped_index] != null:
			has_weapon_equipped = true
			Inventory[current_equipped_index].show()
			for item in itemholder.get_child_count():
				if !itemholder.get_child(item) == current_equipped:
					itemholder.get_child(item).hide()
	if has_weapon_equipped:
		current_equipped = Inventory[current_equipped_index]

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


var damage_popup : PackedScene = preload("res://assets/scenes/damage_popup.tscn")
var last_popup : Node = null
func damage(amount, impulseMult:float = 1, bulletDir:Vector3 = Vector3.ZERO, hitPos : Vector3 = Vector3.ZERO, applyKnockback:bool = true, knockbackAmount:float = 0, hitbox : Hitbox = null):
	var damageamount
	if hitbox == null:
		damageamount = amount
	else:
		damageamount = amount * hitbox.hitboxDmgMultiplier
		last_bone_hit = hitbox.boneId
	
	if Global.isDamageNums:
		if last_popup != null:
			#there exists a previous one
			if last_popup.fall_down:
				last_popup = null
			else:
				last_popup.accumulated_damage += damageamount
				last_popup.global_position = global_position + Vector3.UP * 1.8
		else:
			#it is null
			last_popup = damage_popup.instantiate()
			die.connect(last_popup.start_falling)
			last_popup.global_position = global_position + Vector3.UP * 1.8
			last_popup.accumulated_damage += damageamount
			get_parent().get_parent().add_child(last_popup)

	var localPoint = self.to_local(hitPos)
	var physOffset = localPoint - self.position
	physOffset = self.to_global(physOffset)
	last_impulse = -(bulletDir.normalized() * randf_range(2, impulse_amnt) * impulseMult) + (Vector3.UP * randf_range(4,5))
	impulseDir = physOffset
	Health = Health - damageamount
	GlobalParticles.create_blood(0,hitPos)

	if applyKnockback:
		velocity += -(bulletDir * knockbackAmount)


func pawn_animation(delta):
	pass

func summon_item(item):
	if !itemholder.has_node(str(item)):
		var spawned = item.instantiate()
		spawned.holder = self
		spawned.is_held = true
		itemholder.add_child(spawned)
		Inventory.append(spawned)
		emit_signal("pickedupItem", spawned)
		equipsounds.play()
		if !spawned.is_held:
			spawned.is_held = true

signal die
func kill(bone_hit):
	$Collider.disabled = true
	is_dead = true
	Health = 0
	dropWeapon(current_equipped)
	create_ragdoll(bone_hit)
	anim_tree.active = false
	die.emit()
	hide()
	get_owner().deleteTimer.start()

func create_ragdoll(impulse_bone:int = 0):
	var _ragdoll : Ragdoll = ragdoll.instantiate()
	_ragdoll.global_transform = $Mesh.global_transform
	_ragdoll.pawn_dead = get_parent()
	Global.world.worldMisc.add_child(_ragdoll)
	for bones in _ragdoll.ragdoll_skeleton.get_bone_count():
		_ragdoll.ragdoll_skeleton.set_bone_pose_rotation(bones, $Mesh/Male/MaleSkeleton/Skeleton3D.get_bone_pose_rotation(bones))
		_ragdoll.ragdoll_skeleton.set_bone_pose_position(bones, $Mesh/Male/MaleSkeleton/Skeleton3D.get_bone_pose_position(bones))

	for bone in _ragdoll.ragdoll_skeleton.get_child_count():
		var child = _ragdoll.ragdoll_skeleton.get_child(bone)
		if child is PhysicalBone3D:
			_ragdoll.ragdoll_skeleton.physical_bones_start_simulation()
			child.apply_central_impulse(velocity)
			if child.get_bone_id() == impulse_bone:
				_ragdoll.ragdoll_skeleton.physical_bones_start_simulation()
				child.apply_impulse(last_impulse, impulseDir)
	_ragdoll.target_skeleton = pawn_skeleton
	_ragdoll.bone_hit = last_bone_hit
	_ragdoll.pawn_to_animate = self
	created_ragdoll = _ragdoll


func _on_weapon_lower_timer_timeout():
	is_using = false
	is_aiming = false

func change_to_dead_cam():
	pass

func _on_timer_timeout():
	get_owner().queue_free()

func dropWeapon(weapon):
	if !current_equipped == null:
		var weaponDrop = Weapondb.SpawnableWeapons[str(weapon.name)].instantiate()
		if !weaponDrop == null:
			Global.world.worldMisc.add_child(weaponDrop)
			weaponDrop.global_position = current_equipped.global_position
			weaponDrop.global_rotation = current_equipped.global_rotation
			Inventory.remove_at(current_equipped_index)
			current_equipped.queue_free()
			current_equipped_index =- 1
		else:
			return null

func _slide(
	body: RID,
	from: Transform3D,
	motion: Vector3,
	margin: float = 0.001,
	max_slides: int = 6,
	max_collisions: int = 16
	) -> Vector3:

	for i in range(max_slides):
		var params := PhysicsTestMotionParameters3D.new()
		params.from = from
		params.motion = motion
		params.margin = margin
		params.max_collisions = max_collisions

		var result := PhysicsTestMotionResult3D.new()
		if not PhysicsServer3D.body_test_motion(body, params, result):
			break

		var normal: Vector3 = (
			range(result.get_collision_count())
			.map(func(collision_index): return result.get_collision_normal(collision_index))
			.reduce(func(sum, normal): return sum + normal, Vector3.ZERO)
			.normalized()
		)
		motion = result.get_remainder().slide(normal)
		from = from.translated(result.get_travel())

	return motion

func _step_up(delta: float) -> bool:
	# do step only if grounded
	if not is_on_floor():
		return false

	# cast body upword by step_height
	var up_test_params := PhysicsTestMotionParameters3D.new()
	up_test_params.from = global_transform
	up_test_params.motion = step_height * up_direction
	up_test_params.margin = safe_margin
	if PhysicsServer3D.body_test_motion(get_rid(), up_test_params):
		print("up block")
		return false

	var up_transform = global_transform.translated(step_height * up_direction)
	var slide_motion = (
		_slide(get_rid(), up_transform, direction * delta, safe_margin, max_slides)
		.slide(up_direction)
	)

	# cast body by slide motion
	var forward_test_params := PhysicsTestMotionParameters3D.new()
	forward_test_params.from = up_transform
	forward_test_params.motion = slide_motion
	forward_test_params.margin = safe_margin
	if PhysicsServer3D.body_test_motion(get_rid(), forward_test_params):
		print("fwd block")
		return false

	# cast body downward by step_height
	var down_test_from := up_transform.translated(slide_motion)
	var down_test_params := PhysicsTestMotionParameters3D.new()
	down_test_params.from = down_test_from
	down_test_params.motion = -step_height * up_direction
	down_test_params.margin = safe_margin
	var down_test_result := PhysicsTestMotionResult3D.new()
	if PhysicsServer3D.body_test_motion(get_rid(), down_test_params, down_test_result):
		#global_transform.translated(-down_test_result.get_remainder())
		global_transform = down_test_from.translated(down_test_result.get_travel())
		return true

	return false
