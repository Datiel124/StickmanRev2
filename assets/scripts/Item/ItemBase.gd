extends Node
class_name Pawn_Item
signal itemUsed(shakeAmount)
@export var Item_Resource : ItemResource
@export var holder : CharacterBody3D
@export var is_held = false
@export var is_in_use = false
@onready var sound_player = $SoundPlayer
@onready var muzzle_point = $Muzzle
@onready var Raycaster = $RayCast3D
@onready var collision = $CollisionShape3D
@onready var item_cooldown = $item_cooldown
@onready var can_be_picked_up = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_held:
		self.visible = false
		collision.disabled = true
		$Mesh/ItemModel.set_material_overlay(null)


	item_cooldown.wait_time = Item_Resource.Item_Cooldown
	pass # Replace with function body.

func playSound(sound_type:int):
	sound_player.set_stream(Item_Resource.item_use_sounds[sound_type])
	sound_player.pitch_scale = randf_range(Item_Resource.item_sound_pitch_min, Item_Resource.item_sound_pitch_max)
	sound_player.play()
	pass

func use():
	var bullet = Item_Resource.Projectile.instantiate()
	##Call this function when using the item, takes after the item type described in the item resource
	if !is_in_use:
		is_in_use = true
		itemUsed.emit(Item_Resource.Camera_Shake_Intensity)
		item_cooldown.start()

		if Item_Resource.item_type == 5:
				playSound(0)
				#GlobalParticles.create_bullet_tracer(muzzle_point.global_position, self.rotation, muzzle_point)

		if Item_Resource.item_type == 6:
				playSound(0)
				#GlobalParticles.create_bullet_tracer(muzzle_point.global_position, self.rotation, muzzle_point)

		if Item_Resource.animation_type == 0:
			holder.anim_tree.set("parameters/pistol_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

		if Item_Resource.animation_type == 1:
			holder.anim_tree.set("parameters/badger_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

		holder.is_using = true
		holder.weapon_lower_timer.start()

		if !Item_Resource.Projectile == null:
			var smoke = load("res://assets/particles/weaponSmoke/weaponSmoke.tscn")
			var smokeEffect = smoke.instantiate()
			muzzle_point.add_child(bullet)
			muzzle_point.add_child(smokeEffect)
			bullet.shooter = holder
			bullet.top_level = true

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_held == true:
		lerp_offset(delta)
		set("gravity_scale", 0)
		collision.disabled = true



func lerp_offset(delta):
	self.position.z = lerp(self.position.z, Item_Resource.Item_Position_Offset.z, 5 * delta)
	self.position.y = lerp(self.position.y, Item_Resource.Item_Position_Offset.y, 5 * delta)
	self.position.x = lerp(self.position.x, Item_Resource.Item_Position_Offset.x, 5 * delta)

	self.rotation.z = lerp(self.rotation.z, Item_Resource.Item_Rotation_Offset.z, 5 * delta)
	self.rotation.y = lerp(self.rotation.y, Item_Resource.Item_Rotation_Offset.y, 5 * delta)
	self.rotation.x = lerp(self.rotation.x, Item_Resource.Item_Rotation_Offset.x, 5 * delta)


func _on_item_cooldown_timeout():
	is_in_use = false
