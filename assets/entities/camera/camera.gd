extends CharacterBody3D
class_name playerCam

@onready var Aimcast = $horizontal/vertical/Camera3D/Aimcast
@onready var Killcast = $horizontal/vertical/Camera3D/KillCast
@onready var Camera = $horizontal/vertical/Camera3D
@onready var camera_springarm = $SpringArm3D
@onready var spring_arm_temp = camera_springarm.spring_length
@onready var horiz = $horizontal
@onready var vert = $horizontal/vertical
@onready var dead_cam = false
@onready var hudDisplay = $horizontal/vertical/Camera3D/HUD
@onready var playerNode = load("res://assets/resources/controllers/player/playerController.tscn")

@export var cam_smooth_zoom = 0.1
@export var min_zoom := -0.2
@export var max_zoom := 0.8
@export var cam_zoom_sens = 0.2
@export var cam_speed = 14

var direction = Vector3.ZERO
# Movement state
var acceleration = 3
var vert_velocity = Vector3.ZERO
var total_pitch = 0.0
var mouse_pos = Vector2(0.0,0.0)

##Screenshake
@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise = FastNoiseLite.new()
@export var noise_speed := 50.0

@onready var initial_rotation := Camera.rotation_degrees as Vector3

var trauma := 0.0

var time := 0.0


var c_name = ""
var mp_id

var defaultcamres = load("res://assets/resources/CameraData/DefaultCam.tres")
@export var default_cam_fov = 90
@export var is_freecam = true
@export var attachedPawn : Node3D
@export var CameraDataResource:CameraData

@onready var rot = vert.global_transform.basis.get_euler().y

@export_range(0.001, 1.0) var sensitivity = 0.01

@export var debug_impulse = 9


func _ready():
#	if multiplayer.multiplayer_peer != null:
#		if not is_multiplayer_authority(): return
	Camera.current = true
	Input.set_mouse_mode(2)
	pass # Replace with function body.

func _physics_process(delta):
#	if multiplayer.multiplayer_peer != null:
#		if not is_multiplayer_authority(): return
	##Rotation Setter
	rot = vert.global_transform.basis.get_euler().y
	update_mouselook()
	##Debug Controls
	##Enable/Disable Debug
	if Input.is_action_just_pressed("debug_enable"):
		if Global.debugMode:
			Global.debugMode = false
			Global.notify_warn("Debug controls disabled.", 2, 5)
		else:
			Global.debugMode = true
			Global.notify_warn("Debug controls enabled.", 2, 5)

	if Global.debugMode:
		##Enable Freecam
		if Input.is_action_just_pressed("give_test_item"):
			if !is_freecam:
				for i in Weapondb.SpawnableWeapons.keys():
					attachedPawn.character_pawn.summon_item(Weapondb.SpawnableWeapons[i])
					for wait in 5:
						await get_tree().physics_frame

		##Enable Freecam
		if Input.is_action_just_pressed("freecam_enable"):
			if !is_freecam and !dead_cam:
				Global.notify_fade("Freecam enabled.")
				detach_cam()

		##Posess Pawn
		if Input.is_action_just_pressed("debug_posess"):
			if Aimcast.is_colliding() && is_freecam:
				if Aimcast.get_collider().get_parent() is Pawn_Controller:
					Global.notify_fade("Posessed pawn " + str(Aimcast.get_collider().get_parent()))
					posess_pawn(Aimcast.get_collider().get_parent())
			else:
				Global.notify_warn("Must be looking at a pawn while in freecam to posess.", 2, 5)

		if Input.is_action_just_pressed("pawn_spawn"):
			var spawn_zone = get_node("/root/Global")
			if Aimcast.is_colliding():
				if !Aimcast.get_collision_point() == null:
					Global.notify_fade("Spawned Pawn")
					var tospawn = load("res://assets/entities/pawn/character_pawn.tscn")
					var pawn = tospawn.instantiate()
					pawn.position = Aimcast.get_collision_point()
					pawn.rotation.y = randf_range(0,360)
					spawn_zone.add_child(pawn, true)
					return
			Global.notify_warn("Failed to spawn: Look at a surface to spawn pawn onto.", 2, 3)

	##If freecam is on
	if is_freecam:
		vert.position.x = lerp(vert.position.x, CameraDataResource.cam_offset.x, 5 * delta)

	##If Freecam is not on and is posessing
	Camera.position.z = lerp(Camera.position.z, CameraDataResource.cam_offset.z, 5 * delta)
	horiz.position.y = lerp(horiz.position.y, CameraDataResource.cam_offset.y, 5 * delta)



	if !attachedPawn == null:
		var triggerOnce = true

		if triggerOnce:
			Killcast.add_exception(attachedPawn.character_pawn)
			for bones in attachedPawn.character_pawn.hitBoxes.get_children():
				for hitboxes in bones.get_children():
					Killcast.add_exception(hitboxes)

		if !attachedPawn.character_pawn.has_weapon_equipped:
			if attachedPawn.getMasterController().camera_shoulder == 0:
				vert.position.x = lerp(vert.position.x, CameraDataResource.cam_offset.x, 5 * delta)
			else:
				vert.position.x = lerp(vert.position.x, -CameraDataResource.cam_offset.x, 5 * delta)

		#Set Camera position to equipped weapon shoulder
		if attachedPawn.getMasterController().camera_shoulder == 0 and attachedPawn.character_pawn.has_weapon_equipped == true and !is_freecam:
			vert.position.x = lerp(vert.position.x, CameraDataResource.weapon_equipped_cam_offset.x, 5 * delta)
			pass
		if attachedPawn.getMasterController().camera_shoulder == 1 and attachedPawn.character_pawn.has_weapon_equipped == true and !is_freecam:
			vert.position.x = lerp(vert.position.x, -CameraDataResource.weapon_equipped_cam_offset.x, 5 * delta)
			pass

	##Freecam
	if is_freecam:
		hudDisplay.weaponDisplay.hide()
		hudDisplay.healthStatus.hide()

		direction = Vector3(Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft"), 0, Input.get_action_strength("MoveBackwards") - Input.get_action_strength("MoveForward")).rotated(Vector3.UP, rot)

		if direction != Vector3.ZERO:
			direction = direction.normalized()

		velocity.x = lerp(velocity.x, direction.x * cam_speed, delta * acceleration )
		velocity.z = lerp(velocity.z, direction.z * cam_speed, delta * acceleration )
		velocity.y = lerp(velocity.y, vert_velocity.y * cam_speed, delta * acceleration)

		vert_velocity = Vector3.ZERO
		if Input.is_action_pressed("freecam_up"):
			vert_velocity.y = 1.0
		if Input.is_action_pressed("freecam_down"):
			vert_velocity.y = -1.0




		move_and_slide()

func camera_zoom_lerp():
	spring_arm_temp = clamp(spring_arm_temp, min_zoom, max_zoom)
	camera_springarm.spring_length = lerp(camera_springarm.spring_length, spring_arm_temp, cam_smooth_zoom)

func _input(event):
#	if multiplayer.multiplayer_peer != null:
#		if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		mouse_pos.x += event.relative.x
		mouse_pos.y += event.relative.y

func _process(delta):
		time += delta
		trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
		
		if !is_freecam:
			Camera.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
			Camera.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
			Camera.rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

func posess_pawn(pawn:Node3D):
	await Fade.fade_out(0.3, Color(0,0,0,1),"Diagonal",false,true).finished
	reset_cam()
	attachedPawn = pawn
	var playercontroller = playerNode.instantiate()
	pawn.clearMasterController()
	pawn.add_child(playercontroller)
	pawn.setMasterController(playercontroller)
	get_tree().get_root().get_node("/root/Global").remove_child(self)
	pawn.character_pawn.CameraPosNode.add_child(self)
	pawn.getMasterController().pawnCam = self
	reset_cam()
	pawn.character_pawn.global_rotation = Vector3.ZERO
	CameraDataResource = pawn.controllerScript.CameraResource
	is_freecam = false
	pawn.getMasterController().pawn = pawn.character_pawn
	Fade.fade_in(0.3, Color(0,0,0,1),"GradientVertical",false,true)

func update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_pos *= sensitivity

		var yaw = mouse_pos.x
		var pitch = mouse_pos.y

		mouse_pos = Vector2(0, 0)

		pitch = clamp(pitch, -88 - total_pitch, 88 - total_pitch)
		total_pitch += pitch
		horiz.rotate_y(deg_to_rad(-yaw))
		vert.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))



func reset_cam():
	self.position = Vector3.ZERO

func detach_cam():
	await Fade.fade_out(0.3, Color(0,0,0,1),"Diagonal",false,true).finished
	Killcast.clear_exceptions()
	attachedPawn.getMasterController().enabled = false
	attachedPawn.clearMasterController()
	var detach_pos = Vector3(vert.global_position.x,horiz.global_position.y,self.global_position.z)
	var new_parent = get_node("/root/Global")
	attachedPawn.character_pawn.CameraPosNode.remove_child(self)
	attachedPawn = null
	self.position = detach_pos
	new_parent.add_child(self)
	is_freecam = true
	CameraDataResource = defaultcamres
	Fade.fade_in(0.3, Color(0,0,0,1),"GradientVertical",false,true)


func fov_zoom(zoom, delta):
	Camera.fov = lerpf(Camera.fov, zoom, delta * 8)

func getMidPoint(muzzlepoint):
	var cam = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_content_scale_size()

	var rayOrigin = cam.project_ray_origin(viewport/2)
	var rayEnd = (rayOrigin + cam.project_ray_normal(viewport/2)*600)
	var dir = -(rayEnd - muzzlepoint.global_transform.origin).normalized()
	return dir

func add_trauma(trauma_amount : float, _maxX:float = 10.0, _maxY:float = 10.0, _maxZ:float = 5.0):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
	max_x = _maxX
	max_y = _maxY
	max_z = _maxZ

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.set_seed(_seed)
	return noise.get_noise_1d(time * noise_speed)
