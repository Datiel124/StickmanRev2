extends Marker3D
class_name SpawnPoint
@export_category("Spawn Point")
##What type of spawn is this for? Pawn or Player?
@export_enum("Pawn", "Player", "Special") var spawnType = 1
@export_group("Behavior")
@export_subgroup("Pawn")
@export var pawnSpawnGroup = "Default"
##If the AI type is Random, the pawn will randomly get points from a set of markers, if its Patrol the pawn will get markers from a specific markerSet with a group name specified. If the patrolSubtype is set to random then it will randomly grab markers and walk to their location, otherwise it will sequentially follow markers in sequence.
@export_enum("None", "Patrol", "Random", "Special") var pawnAIType = 2

@export_subgroup("Player")
##Is this spawn point to be used exclusively in multiplayer levels?
@export var mpSpawn = false
