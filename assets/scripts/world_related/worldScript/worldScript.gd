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
##Set the name for this specific scene
@export_category("World Identity")
##What is this worlds name?
@export var worldName = ""
##Describe the world..
@export var worldDescription = ""
## What type of world is this scene? If its a general area the player can explore to find things like items or quests, it'd be an area. If its a zone where the player can save the game or restock on items it'd be a safehouse. If its a sector full of enemies, arena.
@export_enum("Area", "Shop", "Safehouse", "Arena") var worldType = 0

func _ready():
	Global.world = self
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
	pass
	
func getPlayerSpawnPoints(offset:Vector3 = Vector3(0,0,0), pickRandom:bool = true, spawn_idx:int = 0):
	if pickRandom:
		for spawns in playerWorldSpawns.get_children().pick_random():
			return spawns
	else:
		pass
