extends CharacterBody3D


@onready var Aimcast = $horizontal/vertical/Camera3D/Aimcast
@onready var Killcast = $horizontal/vertical/Camera3D/KillCast
@onready var Camera = $horizontal/vertical/Camera3D
@onready var camera_springarm = $SpringArm3D
@onready var spring_arm_temp = camera_springarm.spring_length
@onready var horiz = $horizontal
@onready var vert = $horizontal/vertical
@onready var dead_cam = false
@onready var hudDisplay = $horizontal/vertical/Camera3D/HUD

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



var c_name = ""
var mp_id 

var defaultcamres = load("res://assets/resources/CameraData/DefaultCam.tres")
@export var default_cam_fov = 90
@export var debug_cam_controls = true
@export var is_freecam = true
@export var camera_follow_node : Node3D
@export var CameraDataResource:CameraData

@onready var rot = vert.global_transform.basis.get_euler().y

@export_range(0.001, 1.0) var sensitivity = 0.01

@export var debug_impulse = 9


func _ready():
	if not is_multiplayer_authority(): return
	Camera.current = true
	Input.set_mouse_mode(2)
	pass # Replace with function body.

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	##Rotation Setter
	rot = vert.global_transform.basis.get_euler().y
	update_mouselook()
	##Debug Controls
	if debug_cam_controls:
		##Enable Freecam
		if Input.is_action_just_pressed("give_test_item"):
			if !is_freecam:
				camera_follow_node.character_pawn.summon_item(Weapondb.SpawnableWeapons["Baretta"])
		
		##Enable Freecam
		if Input.is_action_just_pressed("freecam_enable"):
			if !is_freecam and !dead_cam:
				detach_cam()
				
		
		##Posess Pawn
		if Input.is_action_just_pressed("debug_posess"):
			if Aimcast.is_colliding() && is_freecam:
				if Aimcast.get_collider().get_parent() is Pawn_Controller:
					posess_pawn(Aimcast.get_collider().get_parent())
		
		##Debug Kill Pawn
		if Input.is_action_just_pressed("Shoot"):
			if Killcast.is_colliding() && is_freecam:
				if Killcast.get_collider() is PhysicalBone3D:
					if Killcast.get_collider().get_owner() is Pawn_Controller:
						if !Killcast.get_collider().get_owner().character_pawn.is_dead:
							Killcast.get_collider().get_owner().character_pawn.last_bone_hit = Killcast.get_collider().get_bone_id()
							Killcast.get_collider().get_owner().character_pawn.last_impulse = Killcast.get_collision_point().rotated(Vector3.DOWN,rot)
							Killcast.get_collider().get_owner().character_pawn.impulse_amnt = debug_impulse
							GlobalParticles.create_blood(0,Killcast.get_collision_point())
							Killcast.get_collider().get_owner().character_pawn.kill(Killcast.get_collider().get_owner().character_pawn.last_bone_hit)
		
		if Input.is_action_just_pressed("pawn_spawn"):
			var spawn_zone = get_node("/root/Global")
			if Aimcast.is_colliding():
				if !Aimcast.get_collision_point() == null:
					var tospawn = load("res://assets/entities/pawn/character_pawn.tscn")
					var pawn = tospawn.instantiate()
					pawn.position = Aimcast.get_collision_point()
					pawn.rotation.y = randf_range(0,360)
					spawn_zone.add_child(pawn, true)
					
	##If freecam is on
	if is_freecam:
		vert.position.x = lerp(vert.position.x, CameraDataResource.cam_offset.x, 5 * delta)
	
	##If Freecam is not on and is posessing
	Camera.position.z = lerp(Camera.position.z, CameraDataResource.cam_offset.z, 5 * delta)
	horiz.position.y = lerp(horiz.position.y, CameraDataResource.cam_offset.y, 5 * delta)
	
	
	
	if !camera_follow_node == null:
		if !camera_follow_node.character_pawn.has_weapon_equipped:
			if camera_follow_node.character_pawn.camera_shoulder == 0:
				vert.position.x = lerp(vert.position.x, CameraDataResource.cam_offset.x, 5 * delta)
			else:
				vert.position.x = lerp(vert.position.x, -CameraDataResource.cam_offset.x, 5 * delta)
			
		#Set Camera position to equipped weapon shoulder
		if camera_follow_node.character_pawn.camera_shoulder == 0 and camera_follow_node.character_pawn.has_weapon_equipped == true and !is_freecam:
			vert.position.x = lerp(vert.position.x, CameraDataResource.weapon_equipped_cam_offset.x, 5 * delta)
			pass
		if camera_follow_node.character_pawn.camera_shoulder == 1 and camera_follow_node.character_pawn.has_weapon_equipped == true and !is_freecam:
			vert.position.x = lerp(vert.position.x, -CameraDataResource.weapon_equipped_cam_offset.x, 5 * delta)
			pass
		
	##Freecam
	if is_freecam:
		hudDisplay.weaponDisplay.hide()
		
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

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		mouse_pos.x += event.relative.x
		mouse_pos.y += event.relative.y
		


func posess_pawn(pawn:Node3D):
	reset_cam()
	camera_follow_node = pawn
	get_tree().get_root().get_node("/root/Global").remove_child(self)
	pawn.character_pawn.CameraPosNode.add_child(self)
	pawn.character_pawn.pawn_cam = self
	reset_cam()
	pawn.character_pawn.global_rotation = Vector3.ZERO
	CameraDataResource = pawn.character_pawn.CameraResource
	pawn.character_pawn.is_controlled = true
	is_freecam = false

func update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_pos *= sensitivity
		
		var yaw = mouse_pos.x
		var pitch = mouse_pos.y
		
		mouse_pos = Vector2(0, 0)
		
		pitch = clamp(pitch, -90 - total_pitch, 90 - total_pitch)
		total_pitch += pitch
		horiz.rotate_y(deg_to_rad(-yaw))
		vert.rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

			

func reset_cam():
	self.position = Vector3.ZERO

func detach_cam():
	var detach_pos = Vector3(vert.global_position.x,horiz.global_position.y,self.global_position.z)
	var new_parent = get_node("/root/Global")
	camera_follow_node.character_pawn.is_controlled = false
	camera_follow_node.character_pawn.CameraPosNode.remove_child(self)
	camera_follow_node = null
	self.global_position = detach_pos
	new_parent.add_child(self)
	is_freecam = true
	CameraDataResource = defaultcamres


func fov_zoom(zoom, delta):
	Camera.fov = lerpf(Camera.fov, zoom, delta * 8)
