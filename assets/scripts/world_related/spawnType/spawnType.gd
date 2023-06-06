extends Marker3D
class_name SpawnPoint
@export_category("Spawn Point")
##What type of spawn is this for? Pawn or Player?
@export_enum("Pawn", "Player", "Special") var spawnType = 1
@export_group("Behavior")
@export_subgroup("Pawn")
@export var spawnWithWeapon = false
@export_enum("Baretta", "HoneyBadger") var spawnWeapon : String = "Baretta"
@export var randomizePawnColor = true
@export var pawnSpawnGroup = "Default"
##If the AI type is Random, the pawn will randomly get points from a set of markers, if its Patrol the pawn will get markers from a specific markerSet with a group name specified. If the patrolSubtype is set to random then it will randomly grab markers and walk to their location, otherwise it will sequentially follow markers in sequence.
@export_enum("None", "Patrol", "Random", "Special") var pawnAIType = 2

@export_subgroup("Player")
##Is this spawn point to be used exclusively in multiplayer levels?
@export var mpSpawn = false
##Spawned Pawn
var spawnedPawn 

func _ready():
	pass

func initSpawn():
	var tospawn = load("res://assets/entities/pawn/character_pawn.tscn")
	var pawn = tospawn.instantiate()
		
	if spawnType == 0:
		pawn.position = self.global_position
		if pawnAIType == 0:
			#pawn.rotation.y = randf_range(0,360)
			Global.world.worldPawns.add_child(pawn, true)
		elif pawnAIType == 1:
			#pawn.rotation.y = randf_range(0,360)
			Global.world.worldPawns.add_child(pawn, true)
		elif pawnAIType == 2:
			var aiController = load("res://assets/resources/controllers/ai/baseAIController.tscn")
			var controller = aiController.duplicate().instantiate()
			#awn.rotation.y = randf_range(0,360)
			Global.world.worldPawns.add_child(pawn, true)
			pawn.setMasterController(controller)
			pawn.character_pawn.add_child(controller)
			controller.set_owner(pawn)
		spawnedPawn = pawn.character_pawn
		if randomizePawnColor:
			pawn.character_pawn.randomizePawnColor()
		if spawnWithWeapon:
			spawnedPawn.summon_item(Weapondb.SpawnableWeapons[spawnWeapon])
			spawnedPawn.current_equipped_index = 1

