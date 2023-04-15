extends Node
class_name WorldScene

## What type of world is this scene? If its a general area the player can explore to find things like items or quests, it'd be an area. If its a zone where the player can save the game or restock on items it'd be a safehouse. If its a sector full of enemies, arena.
@export_enum("Area", "Shop", "Safehouse", "Arena") var worldType = 0

##Set the name for this specific scene
@export var worldName = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.world = self
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getSpawnPoints(offset:Vector3 = Vector3(0,0,0)):
	pass
	
