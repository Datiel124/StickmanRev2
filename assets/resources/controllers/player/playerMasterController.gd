extends masterController
class_name playerMasterController
##Enable controller
var enabled = true
##Player Pawn
var pawn
##Player Camera
var pawnCam
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
			##Set the mesh to look at the camera direction
			pawn.pawnMesh.rotation.y = lerp_angle(pawn.pawnMesh.rotation.y, pawn.rot, delta * turnRate)
			#Set Rotation vector to Camera pos
			pawn.rot = pawnCam.rot
			
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
			if pawn.has_weapon_equipped:
				pawnCam.hudDisplay.weaponDisplay.show()
				pawnCam.hudDisplay.weaponDisplayName.text = pawn.current_equipped.Item_Resource.ItemName
				if !pawn.current_equipped.Item_Resource.itemIcon == null:
					pawnCam.hudDisplay.weaponDisplayTexture.texture = pawn.current_equipped.Item_Resource.itemIcon
				else:
					var unknownpng = load("res://assets/textures/weaponIcons/unknown/unknown.png")
					pawnCam.hudDisplay.weaponDisplayTexture.texture = unknownpng
			else:
				pawnCam.hudDisplay.weaponDisplay.hide()
			
			
			##Aim Rotation turn rate set
			if pawn.is_aiming:
				turnRate = 25
				pawn.ik_marker.rotation.x = -pawnCam.vert.rotation.x
			else:
				turnRate = default_turn_rate


func _input(input):
	if !pawn == null:
		if enabled:
			#Swap Shoulder
			if Input.is_action_just_pressed("swap_shoulder"):
				swap_shoulder()
			##Scroll weapon list up
			if Input.is_action_just_released("mwheel_up"):
				if !pawn.current_equipped_index > pawn.Inventory.size():
					pawn.current_equipped_index = pawn.current_equipped_index + 1

			##Scroll weapon list down
			if Input.is_action_just_released("mwheel_down"):
				if !pawn.current_equipped_index < 0:
					pawn.current_equipped_index = pawn.current_equipped_index - 1
			
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

func checkIfKillcastColliding():
	return pawnCam.Killcast.is_colliding()
