extends masterController
class_name playerMasterController
##Enable controller
var enabled = true
##Player Pawn
var pawn : Pawn:
	set(value):
		pawn = value
##Player Camera
var pawnCam
#Tilt
var tiltFactor = 0.02
## Player mesh turn rate
var turnRate = 11
var default_turn_rate = 11
#Camera Data
@export var CameraResource : CameraData = load("res://assets/resources/CameraData/PawnDefaultPlayerCam.tres")

## Camera shoulder position, 0 = Right, 1 = left
@export_enum("Right", "Left") var camera_shoulder = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !pawn == null:
		if enabled:
			##Weapon Switch Sound
			if !pawn.item_changed.is_connected(itemChange):
				pawn.item_changed.connect(itemChange)
			
			##Pawn Death
			if !pawn.die.is_connected(pawnCam.detach_cam):
				pawn.die.connect(pawnCam.detach_cam)

			##Connect Item picked up signal
			if !pawn.pickedupItem.is_connected(itemPickedup):
				pawn.pickedupItem.connect(itemPickedup)
			##Tie shot signal
			if pawn.has_weapon_equipped:
				if !pawn.current_equipped.itemUsed.is_connected(shotFired):
					pawn.current_equipped.itemUsed.connect(shotFired)

			##Set the mesh to look at the camera direction
			pawn.pawnMesh.rotation.y = lerp_angle(pawn.pawnMesh.rotation.y, pawn.rot, delta * turnRate)
			#Set Rotation vector to Camera pos
			pawn.rot = pawnCam.rot

			##Enable status for HUD
			if !pawnCam.hudDisplay.healthStatus.visible == true:
				pawnCam.hudDisplay.healthStatus.show()

			##Set HP bar to pawn HP
			pawnCam.hudDisplay.hpBar.value = lerpf(pawnCam.hudDisplay.hpBar.value, pawn.Health, delta*8)

			##Check if the player is shooting
			if Input.is_action_pressed("Shoot"):
				if !pawn.current_equipped == null:
					pawn.current_equipped.use()
			##Check if the player is aiming
			if Input.is_action_pressed("Aim"):
				if !pawn.is_using:
					pawn.is_aiming = true
				pawn.is_using = false
				pawnCam.fov_zoom(pawnCam.default_cam_fov - 25, delta)
			else:
				pawnCam.fov_zoom(pawnCam.default_cam_fov, delta)

			if !Input.is_action_pressed("Aim"):
				if !pawn.is_using:
					pawn.is_aiming = false

			##Set weapon icon for the hud when the player has a weapon equipped.
			var animationPlayed = false
			if pawn.has_weapon_equipped:
				if !pawnCam.hudDisplay.weaponDisplay.visible:
					pawnCam.hudDisplay.weaponDisplay.show()
				pawnCam.hudDisplay.weaponDisplayName.text = pawn.current_equipped.Item_Resource.ItemName
				if !pawn.current_equipped.Item_Resource.itemIcon == null:
					pawnCam.hudDisplay.weaponDisplayTexture.texture = pawn.current_equipped.Item_Resource.itemIcon
				else:
					var unknownpng = load("res://assets/textures/weaponIcons/unknown/unknown.png")
					pawnCam.hudDisplay.weaponDisplayTexture.texture = unknownpng
			else:
				pawnCam.hudDisplay.weaponDisplay.hide()
				animationPlayed = true


			##Aim Rotation turn rate set
			if pawn.is_aiming:
				turnRate = 25
				pawn.ik_marker.rotation.x = -pawnCam.vert.rotation.x
			else:
				turnRate = default_turn_rate
		else:
			if pawn.die.is_connected(pawnCam.detach_cam):
				pawn.die.disconnect(pawnCam.detach_cam)
			if pawn.pickedupItem.is_connected(itemPickedup):
				pawn.pickedupItem.disconnect(itemPickedup)

func _physics_process(delta):
	if !pawn == null:
		##Set player movement direction
		pawn.direction = Vector3(pawn.MoveRight - pawn.MoveLeft, 0, pawn.MoveBackwards - pawn.MoveForward).rotated(Vector3.UP, pawn.rot)
	
func _input(input):
	if !pawn == null:
		if enabled:
			#Drop weapon
			if Input.is_action_just_pressed("game_dropWeapon"):
				pawn.dropWeapon(pawn.current_equipped)
			
			#Swap Shoulder
			if Input.is_action_just_pressed("swap_shoulder"):
				swap_shoulder()
			##Scroll weapon list up
			if Input.is_action_just_pressed("mwheel_up") and !Input.is_action_pressed("Shoot"):
				pawn.current_equipped_index = pawn.current_equipped_index + 1

			##Scroll weapon list down
			if Input.is_action_just_pressed("mwheel_down") and !Input.is_action_pressed("Shoot"):
				pawn.current_equipped_index = pawn.current_equipped_index - 1

			##Pause menu toggle
			if Input.is_action_just_pressed("game_pause"):
				Global.notify_warn("No pause menu yet.. Just Alt+F4 if you need to leave the game.", 2, 1)
			#Set movement strength parameters
			pawn.MoveLeft = Input.get_action_strength("MoveLeft")
			pawn.MoveRight = Input.get_action_strength("MoveRight")
			pawn.MoveForward = Input.get_action_strength("MoveForward")
			pawn.MoveBackwards = Input.get_action_strength("MoveBackwards")

##Swaps the shoulder
func swap_shoulder():
	if camera_shoulder == 0:
		camera_shoulder = 1
	else:
		camera_shoulder = 0

func getKillcastPoint():
	if pawnCam.Killcast.is_colliding():
		return pawnCam.Killcast.get_collision_point()

func getKillcastCollider():
	if pawnCam.Killcast.is_colliding():
		return pawnCam.Killcast.get_collider()

func getKillcastNormal():
	if pawnCam.Killcast.is_colliding():
		return pawnCam.Killcast.get_collision_normal()

func checkIfKillcastColliding():
	return pawnCam.Killcast.is_colliding()

func shotFired(shakeAmount):
	pawnCam.add_trauma(shakeAmount)

func itemPickedup(spawned):
	Global.notify_fade("Picked up " + str(spawned.name), 2, 5)

func itemChange():
	if !pawn.current_equipped_index > pawn.Inventory.size()-1:
		if !pawn.current_equipped_index <= 0:
			pawn.anim_tree.set("parameters/weapon_blend/blend_amount", 0)
	
		if !pawn.equipsounds.playing:
			pawnCam.add_trauma(0.19)
			pawn.equipsounds.play()
