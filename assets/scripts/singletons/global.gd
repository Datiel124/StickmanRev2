extends Node

var user_dir = DirAccess.open("user://")
var unix_time: float = Time.get_unix_time_from_system()
var datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)

# Get the system time
var system_time: String = Time.get_time_string_from_system()

## If the game is multiplayer
var is_multiplayer_game = false
## If is fullscreen
var is_fullscreen = true

#MP Related
var port = 7777
var ip = "localhost"

var player_name = ""

##World Stuff
var mp_spawner = MultiplayerSpawner.new()

#Preloads
var stickpawn = preload("res://assets/entities/pawn/character_pawn.tscn")
var camera_ent = preload("res://assets/entities/camera/camera.tscn")


var config_file = ConfigFile.new()

var settingsvars = config_file.load("user://settings/settings.sav")

# Called when the node enters the scene tree for the first time.
func _process(delta):
		
	if Input.is_action_just_pressed("fullscreen_toggle"):
		fullscreen_toggle()
			
	if Input.is_action_just_pressed("screenshot"):
		screenshot()

func _ready():
	load_settings()
	add_child(mp_spawner)
	mp_spawner.name = "MPSpawner"
	mp_spawner.add_spawnable_scene("res://assets/entities/camera/camera.tscn")
	mp_spawner.add_spawnable_scene("res://assets/entities/pawn/character_pawn.tscn")
	mp_spawner.set_spawn_path('/root/Global')



func load_settings():
	print("Loading Settings!")
	if settingsvars != OK:
		print("Couldn't find any setting save data, creating..")
		save_settings()
	else:
		print("Found settings config! Loading now..")
		for setting in config_file.get_sections():
			is_fullscreen = config_file.get_value(setting, "fullscreen")

##Adds a player/camera to the scene - MULTIPLAYER USAGE ONLY
func add_player(pos:Vector3 = Vector3(0,0,0), peer_id:int = 0):
	var player_camera = camera_ent.instantiate()
	var player_pawn = stickpawn.instantiate()
	var playerController = load("res://assets/resources/controllers/player/playerMasterController.gd")
	if is_multiplayer_game:
		add_child(player_pawn)
		player_camera.c_name = player_name
		player_camera.name = str(peer_id)
		player_camera.mp_id = str(peer_id)
		player_pawn.name = str(peer_id)
		player_pawn.set_multiplayer_authority(str(peer_id).to_int())
		player_camera.camera_follow_node = player_pawn
		player_camera.CameraDataResource = player_pawn.character_pawn.CameraResource
		player_camera.set_multiplayer_authority(str(peer_id).to_int())
		player_pawn.character_pawn.CameraPosNode.add_child(player_camera)
		player_pawn.character_pawn.pawn_cam = player_camera
		player_pawn.character_pawn.is_controlled = true
		player_pawn.position = pos
		player_camera.is_freecam = false
	else:
		add_child(player_pawn)
		player_camera.camera_follow_node = player_pawn
		player_pawn.setMasterController(playerController)
		player_camera.CameraDataResource = player_pawn.getMasterController().CameraResource
		player_pawn.getMasterController().CameraPosNode.add_child(player_camera)
		player_pawn.getMasterController().pawnCam = player_camera
		player_pawn.position = pos
		player_camera.is_freecam = false

func save_settings():
	if !user_dir.dir_exists("user://settings"):
		user_dir.make_dir("user://settings")
		save_settings()
	config_file.set_value("Setting_1", "fullscreen", is_fullscreen)
	print("Saved configs!")
	config_file.save("user://settings/settings.sav")

func fullscreen_toggle():
	if is_fullscreen:
		is_fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		is_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
func screenshot():
	print("Initializing screenshot!")
	var screenshot_count = 0
	var screenshot = get_viewport().get_texture().get_image()

	if user_dir.dir_exists("user://screenshots"):
		var screenshot_dir = DirAccess.open("user://screenshots/")
		print(screenshot_dir.get_current_dir())
		screenshot_count = screenshot_dir.get_files().size() + 1
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		screenshot_count = screenshot_count + 1
	else:
		user_dir.make_dir("screenshots")
		var screenshot_dir = DirAccess.open("user://screenshots/")
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		screenshot_count = screenshot_count + 1
	print("Saved screenshot!")
