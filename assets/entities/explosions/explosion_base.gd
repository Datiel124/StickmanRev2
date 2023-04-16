extends Node3D


@export var impulse : = 500.0
@export var damage : float = 200.0
@export_subgroup("Falloff")
@export var impulse_falloff : Curve
@export var damage_falloff : Curve


func _ready() -> void:
	for i in $Particles.get_children():
		i.emitting = true

	explode()

	for particles in $Particles.get_children():
		while particles.emitting:
			await get_tree().process_frame
	queue_free()


#do damage etc
func explode():
	await get_tree().physics_frame
	var radius = $Area3D/CollisionShape3D.shape.radius
	var hit = $Area3D.get_overlapping_bodies().filter(func(shit) : return shit is Hitbox)

	for tgt in hit:
		var dist = tgt.global_position.distance_to(global_position)
		var hit_dmg = damage_falloff.sample(dist / radius)
		var hit_impulse = damage_falloff.sample(dist / radius)

		tgt.damage(hit_dmg, 1, global_position.direction_to(hit.global_position), tgt.global_position, true, hit_impulse)
