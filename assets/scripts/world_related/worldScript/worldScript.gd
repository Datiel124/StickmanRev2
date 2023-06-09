extends Node
class_name WorldScene

@onready var worldSpawns = $Spawns
@onready var playerWorldSpawns = $Spawns/playerSpawns
@onready var pawnWorldSpawns = $Spawns/pawnSpawns
@onready var worldEnvironment = $Environment
@onready var worldGeometry = $Geometry
@onready var worldPawns = $Pawns
@onready var worldProps = $Props
@onready var worldMisc = $Misc
@onready var worldParticles = $Misc/Particles
@onready var worldWaypoints = $Misc/WaypointNodes
@onready var playerPawns = $Pawns/Players
##Set the name for this specific scene
@export_category("World Identity")
##What is this worlds name?
@export var worldName = ""
##Describe the world..
@export var worldDescription = ""
## What type of world is this scene? If its a general area the player can explore to find things like items or quests, it'd be an area. If its a zone where the player can save the game or restock on items it'd be a safehouse. If its a sector full of enemies, arena.
@export_enum("Area", "Shop", "Safehouse", "Arena") var worldType = 0

@export_category("Debug Parameters")
## Spawn Type to use when loading the scene
@export_enum("Player","Camera","None") var spawnType = 0 
##Spawn AI pawns at their respective positions when loading the world.
@export var spawnPawnsOnLoad : bool = true
func _enter_tree():
	Global.world = self

func _ready():
	##Spawn a player at a point.
	if !Global.is_multiplayer_game:
		Global.add_player(getPlayerSpawnPoints(Vector3.ZERO,true).global_position)
	else:
		spawnPawnsOnLoad = false
		
		
	##Spawn pawns at their respective points.
	if spawnPawnsOnLoad == true:
		spawnPawns()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
	pass
	
func getPlayerSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
	if pickRandom:
		var spawnZone = playerWorldSpawns.get_children().pick_random()
		if spawnZone is SpawnPoint:
			if spawnZone.spawnType == 1:
				return spawnZone
	else:
		pass
		
func spawnPawns():
	for spawn in pawnWorldSpawns.get_children():
		if spawn is SpawnPoint:
			spawn.initSpawn()
