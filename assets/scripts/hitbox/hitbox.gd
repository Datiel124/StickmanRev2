class_name Hitbox
extends RigidBody3D

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
	
	$AudioStreamPlayer3D.stream = getCustomSound()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getCustomSound():
	return customSound

func damage(amount, impulseMult:int = 0, bulletDir:Vector3 = Vector3.ZERO, hitPos : Vector3 = Vector3.ZERO, applyKnockback:bool = false, knockbackAmount:int = 0):
	var damageamount = amount * hitboxDmgMultiplier
	var localPoint = self.to_local(hitPos)
	var physOffset = localPoint - self.position
	physOffset = self.to_global(physOffset)
	pawn.character_pawn.last_impulse = -(bulletDir.normalized() * randf_range(2,pawn.character_pawn.impulse_amnt) * impulseMult) + (Vector3.UP * randf_range(4,5))
	pawn.character_pawn.impulseDir = physOffset
	pawn.character_pawn.Health = pawn.character_pawn.Health - damageamount
	pawn.character_pawn.last_bone_hit = boneId
	GlobalParticles.create_blood(0,hitPos)
	$AudioStreamPlayer3D.play()
	
	if applyKnockback:
		pawn.character_pawn.velocity = -(bulletDir * knockbackAmount)
