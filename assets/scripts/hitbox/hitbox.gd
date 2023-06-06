class_name Hitbox
extends Node3D

var boneId : int
@onready var pawn = get_owner()
@export var customSound : AudioStream

##How much additional damage does this specific hitbox do
@export var hitboxDmgMultiplier = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if !get_parent() == null:
		if get_parent() is BoneAttachment3D:
			boneId = get_parent().get_bone_idx()

	$AudioStreamPlayer3D.stream = getCustomSound()
	pass # Replace with function body.


func getCustomSound():
	return customSound


signal _take_damage(amount, impulseMult, bulletDir:Vector3, hitPos : Vector3, applyKnockback:bool, knockbackAmount:float, which,)
func damage(amount, impulseMult:float = 1, bulletDir:Vector3 = Vector3.ZERO, hitPos : Vector3 = Vector3.ZERO, applyKnockback:bool = true, knockbackAmount:float = 0):
	_take_damage.emit(amount, impulseMult, bulletDir, hitPos, applyKnockback, knockbackAmount, self)
	$AudioStreamPlayer3D.play()
