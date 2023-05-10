extends Node

var user_dir = DirAccess.open("user://")
var unix_time: float = Time.get_unix_time_from_system()
var datetime_dict: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)

##Debug mode
var debugMode : bool = false

# Get the system time
var system_time: String = Time.get_time_string_from_system()

## If the game is multiplayer
var is_multiplayer_game = false
## If is fullscreen
var is_fullscreen = true
## Damage numbers
var isDamageNums = true
## Ingame Globals
var world : WorldScene

##World Stuff
var ambientMusic = AudioStreamPlayer.new()
var mp_spawner = MultiplayerSpawner.new()
var notif_hud = preload("res://assets/scripts/singletons/Notifications.tscn").instantiate()

#Preloads
var stickpawn = preload("res://assets/entities/pawn/character_pawn.tscn")
var camera_ent = preload("res://assets/entities/camera/camera.tscn")


var config_file = ConfigFile.new()

var settingsvars = config_file.load("user://settings/settings.sav")

var num_ragdolls : int = 0:
	set(value):
		num_ragdolls = max(value, 0)
var max_ragdolls : int = 8
# Called when the node enters the scene tree for the first time.
var clicksnap = preload("res://assets/sounds/ui/uipopup.wav")
func _process(delta):
	
	if Input.is_action_just_pressed("fullscreen_toggle"):
		fullscreen_toggle()

	if Input.is_action_just_pressed("screenshot"):
		var path = screenshot()
		Global.notify_click("Took screenshot '"+ path +"' (Click to view)", open_screenshot.bind(path), 2, 8)

	if num_ragdolls > max_ragdolls and (Engine.get_process_frames() % 5 == 0):
		get_tree().get_nodes_in_group("ragdolls")[0].queue_free()


var ss_sound = preload("res://assets/sounds/ui/uiSoft.wav")
func open_screenshot(path):
	var new_audio = AudioStreamPlayer.new()
	new_audio.stream = ss_sound
	add_child(new_audio)
	#new_audio.play()
	OS.shell_open(ProjectSettings.globalize_path(path))
	new_audio.finished.connect(new_audio.queue_free)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	add_child(mp_spawner)
	add_child(notif_hud)
	ambientMusic.bus = "AmbientMusic"
	add_child(ambientMusic)

func generate_name() -> String:
	var outname = ""

	var before = ["Jum", "Ge", "Po"]
	var middleA = ["ba", "bo", "fi", "lo", "yum"]
	var middleB = ["bin", "sta", "mil"]
	var after = ["ba", "bo", "tam"]

	var completed

	outname += before.pick_random()
	match outname[-1]:
		"o":
			outname += middleB.pick_random()
		"e":
			outname += middleA.pick_random()
		"m":
			outname += middleB.pick_random()
	outname += after.pick_random()

	return outname


func validate_name(check : String) -> bool:
	#just a simple regex to validate a username
	var regex = RegEx.create_from_string("\\w+")
	var result = regex.search(check)
	return result.strings[0].length() > 0


func load_settings():
	print("Loading Settings!")
	if settingsvars != OK:
		print("Couldn't find any setting save data, creating..")
		save_settings()
	else:
		print("Found settings config! Loading now..")
		for setting in config_file.get_sections():
			is_fullscreen = config_file.get_value(setting, "fullscreen")


##Adds a player/camera to the scene
func add_player(pos:Vector3 = Vector3(0,0,0), peer_id:int = 0):
	var player_camera = camera_ent.instantiate()
	var player_pawn = stickpawn.instantiate()

	var is_me := peer_id == multiplayer.get_unique_id()

	var playerController = load("res://assets/resources/controllers/player/playerController.tscn")
	var controller = playerController.instantiate()
	controller.pawn = player_pawn
	world.playerPawns.add_child(player_pawn)
	player_pawn.character_pawn.add_child(controller)
	player_pawn.name += str(peer_id)
	if Networking.peer_data.has(peer_id):
		player_pawn.character_pawn.nametag.text = Networking.get_peer_data(peer_id).player_name
	player_camera.attachedPawn = player_pawn
	player_camera.name += str(peer_id)
	player_pawn.setMasterController(controller)
	player_pawn.getMasterController().pawn = player_pawn.character_pawn
	player_camera.CameraDataResource = player_pawn.getMasterController().CameraResource
	player_pawn.getMasterController().pawnCam = player_camera
	player_pawn.character_pawn.CameraPosNode.add_child(player_camera)
	player_camera.Camera.current = is_me
	player_pawn.position = pos
	player_camera.is_freecam = false
	player_camera.set_multiplayer_authority(str(player_camera.name).to_int())
	#player_pawn.set_multiplayer_authority(str(player_pawn.name).to_int())


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

func screenshot() -> String:
	print("Initializing screenshot!")
	var screenshot_count = 0
	var screenshot = get_viewport().get_texture().get_image()

	var savedfilepath
	if user_dir.dir_exists("user://screenshots"):
		var screenshot_dir = DirAccess.open("user://screenshots/")
		print(screenshot_dir.get_current_dir())
		screenshot_count = screenshot_dir.get_files().size() + 1
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	else:
		user_dir.make_dir("screenshots")
		var screenshot_dir = DirAccess.open("user://screenshots/")
		screenshot.save_png("user://screenshots/screenshot_" + str(screenshot_count) + ".png")
		savedfilepath = "user://screenshots/screenshot_" + str(screenshot_count) + ".png"
		screenshot_count = screenshot_count + 1
	print("Saved screenshot!")
	return savedfilepath


enum NOTIF_POSITION{topleft, topcenter, topright, bottomleft, bottomcenter, bottomright}
func notify_fade(text : String, position : NOTIF_POSITION = 2, fade_time : float = 3.0):
	var new_notif
	var container = notif_hud.hud_positions[position]

	new_notif = notif_hud.notif_fade.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif


func notify_warn(text : String, position : NOTIF_POSITION = 2, fade_time : float = -1, texture : Texture = notif_hud.warning_texture):
	var new_notif
	var container = notif_hud.hud_positions[position]

	new_notif = notif_hud.notif_warn.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	new_notif.set_warn_params.call(texture, fade_time)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif


func notify_click(text : String, call_on_click : Callable, position : NOTIF_POSITION = 2, fade_time : float = -1, binds : Array = []):
	var new_notif : Control
	var container = notif_hud.hud_positions[position]

	new_notif = notif_hud.notif_click.instantiate()
	container.add_child(new_notif)
	set_notif_flags(new_notif, position)

	new_notif.set_text(text)
	new_notif.set_click_params.call(call_on_click, binds, fade_time)
	if fade_time > 0:
		new_notif.timer.start(fade_time)
	return new_notif


func set_notif_flags(new_notif, position) -> void:
	match position % 3:
		0:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		1:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		2:
			new_notif.size_flags_horizontal = Control.SIZE_SHRINK_END


func notify_custom(node : Control, position : NOTIF_POSITION) -> Control:
	var container = notif_hud.hud_positions[position]
	container.add_child(node)
	set_notif_flags(node, position)
	return node



func getAmbientSongs():
	var songFiles = DirAccess.open("res://assets/music/ambient/")
	var songs = []
	songFiles.list_dir_begin()
	
	while true:
		var song = songFiles.get_next()
		if song == "":
			break
		elif not song.begins_with(".") and !song.get_extension() == "import":
			songs.append(song)
			print(song)
	
	songFiles.list_dir_end()
	
	return songs

func playAmbientSong():
	var songStream = AudioStreamMP3.new()
	var song = FileAccess.open("res://assets/music/ambient/" + getAmbientSongs().pick_random(), FileAccess.READ)
	songStream.data = song.get_buffer(song.get_length())
	ambientMusic.stream = songStream
	ambientMusic.set_bus("AmbientMusic")
	ambientMusic.play()


func detect_surface(result, position) -> StringName:
	var matType : StringName
	var particle : PackedScene
	var bulletHole : PackedScene
	var hitSound : AudioStream
	
	if result.is_in_group("Flesh"):
		matType = "Flesh"
		hitSound = SoundLibrary.soundHitFleshStream
	elif result.is_in_group("Default"):	
		matType = "Default"
		hitSound = SoundLibrary.soundHitCementStream
		bulletHole = bulletHoleLibrary.bulletHoleDefault
	else:
		matType = "Default"
		hitSound = SoundLibrary.soundHitCementStream
		bulletHole = bulletHoleLibrary.bulletHoleDefault
		
	if result.has_method("getCustomSound"):
		var soundSpawn = result.customSound
		if soundSpawn:
			hitSound = result.customSound
	else:
		print("Unable to play sound. Assign one.")
		
	if !hitSound == null:
		Global.spawnSoundAtPosition(result,position, hitSound)
	if !bulletHole == null:
		spawnBulletHoleAtPosition(result,bulletHole,position)
	return matType
	
func spawnSoundAtPosition(owner:Node,position:Vector3,sound:AudioStream):
	var soundPlayer = HitSoundPlayer.new()
	owner.add_child(soundPlayer)
	soundPlayer.global_transform.origin = position
	soundPlayer.bus = "Sounds"
	soundPlayer.stream = sound
	soundPlayer.volume_db = -7
	soundPlayer.play()	

func spawnBulletHoleAtPosition(owner:Node,_bulletHole:PackedScene, position:Vector3):
	var bulletHole = _bulletHole.instantiate()
	owner.add_child(bulletHole)
	bulletHole.global_transform.origin = position
	bulletHole.look_at(position, Vector3(1,1,0))
	
