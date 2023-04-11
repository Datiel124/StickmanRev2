extends RigidBody3D
class_name Hitbox

var boneId : int
@onready var pawn = get_owner()
@export var customSound : AudioStream

##How much additional damage does this specific hitbox do
@export var hitboxDmgMultiplier = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if !get_parent() == null:
		if get_parent() is BoneAttachment3D:
			boneId = get_parent().get_bone_idx()
	
	print(pawn)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getCustomSound():
	return customSound

func damage(amount, bulletDir:Vector3 = Vector3.ZERO, hitPos : Vector3 = Vector3.ZERO):
	var damageamount = amount * hitboxDmgMultiplier
	pawn.character_pawn.Health = pawn.character_pawn.Health - damageamount
	pawn.character_pawn.last_bone_hit = boneId
	GlobalParticles.create_blood(0,hitPos)
	print(damageamount)
