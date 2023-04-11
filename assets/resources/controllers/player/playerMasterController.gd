extends Pawn_Controller
class_name playerMasterController
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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	##Check if the player is alive first..
	if !character_pawn.is_dead:
		##Set the mesh to look at the camera direction
		character_pawn.pawnMesh.rotation.y = lerp_angle(character_pawn.pawnMesh.rotation.y, character_pawn.rot, delta * character_pawn.turnRate)
		#Set Rotation vector to Camera pos
		character_pawn.rot = pawnCam.rot
		
		##Check if the player is shooting
		if Input.is_action_pressed("Shoot"):
			if !character_pawn.current_equipped == null:
				character_pawn.current_equipped.use()
		##Check if the player is aiming
		if Input.is_action_pressed("Aim"):
			if !character_pawn.is_using:
				character_pawn.is_aiming = true
			character_pawn.is_using = false
			character_pawn.pawn_cam.fov_zoom(pawnCam.default_cam_fov - 25, delta)
		else:
			character_pawn.pawn_cam.fov_zoom(pawnCam.default_cam_fov, delta)

		if !Input.is_action_pressed("Aim"):
			if !character_pawn.is_using:
				character_pawn.is_aiming = false
				
		##Set weapon icon for the hud when the player has a weapon equipped.
		if character_pawn.has_weapon_equipped:
			pawnCam.hudDisplay.weaponDisplay.show()
			pawnCam.hudDisplay.weaponDisplayName.text = character_pawn.current_equipped.Item_Resource.ItemName
			if !character_pawn.current_equipped.Item_Resource.itemIcon == null:
				pawnCam.hudDisplay.weaponDisplayTexture.texture = character_pawn.current_equipped.Item_Resource.itemIcon
			else:
				var unknownpng = load("res://assets/textures/weaponIcons/unknown/unknown.png")
				pawnCam.hudDisplay.weaponDisplayTexture.texture = unknownpng
		else:
			pawnCam.hudDisplay.weaponDisplay.hide()
		
		
		##Aim Rotation turn rate set
		if character_pawn.is_aiming:
			turnRate = 25
			character_pawn.ik_marker.rotation.x = -pawnCam.vert.rotation.x
		else:
			turnRate = default_turn_rate


func _unhandled_input(input):
		#Swap Shoulder
		if Input.is_action_just_pressed("swap_shoulder"):
			swap_shoulder()
		##Scroll weapon list up
		if Input.is_action_just_released("mwheel_up"):
			if !character_pawn.current_equipped_index > character_pawn.Inventory.size():
				character_pawn.current_equipped_index = character_pawn.current_equipped_index + 1

		##Scroll weapon list down
		if Input.is_action_just_released("mwheel_down"):
			if !character_pawn.current_equipped_index < 0:
				character_pawn.current_equipped_index = character_pawn.current_equipped_index - 1
		
		#Set movement strength parameters
		character_pawn.MoveLeft = Input.get_action_strength("MoveLeft")
		character_pawn.MoveRight = Input.get_action_strength("MoveRight")
		character_pawn.MoveForward = Input.get_action_strength("MoveForward")
		character_pawn.MoveBackwards = Input.get_action_strength("MoveBackwards")

##Swaps the shoulder
func swap_shoulder():
	if camera_shoulder == 0:
		camera_shoulder = 1
	else:
		camera_shoulder = 0
