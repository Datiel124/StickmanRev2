extends Resource
class_name ItemResource

## Item name
@export var ItemName : String
## Position offset for when the item is equipped.
@export var Item_Position_Offset : Vector3
## Rotation offset for when the item is equipped.
@export var Item_Rotation_Offset : Vector3
@export var Item_Cooldown = 0.5
@export var Damage = 5
@export var Physics_Push_Threshold = 2
@export var Ammo_bullets = 16
@export var Ammo_mag = 8
@export var Camera_Shake_Intensity = 0.5
@export var item_use_sounds : Array[AudioStream]
@export var item_sound_pitch_min = 1
@export var item_sound_pitch_max = 1.3
@export var item_use_animation : Animation
## Which arm will be animated with this item equipped. By default both arms will be animated
@export_enum("Left Arm", "Right Arm", "Both Arms") var arm_filters = 2
@export_enum("BarettaPistol", "HoneybadgerRifle") var animation_type = 0
@export_enum("Item","Melee", "Shotgun", "Explosive", "Throwable", "Automatic", "SemiAutomatic") var item_type = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
