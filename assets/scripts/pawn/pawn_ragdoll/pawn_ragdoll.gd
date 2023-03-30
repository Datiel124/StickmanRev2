
extends Node3D
class_name Ragdoll

var ragdoll_health = 15
var bone_hit = 0
var pawn_to_animate : CharacterBody3D
var death_sound_played = false

@export var pawn_dead:Node3D

@export var active_ragdoll_enabled : bool
@export var target_skeleton: Skeleton3D

@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

@onready var body = $Mesh
@onready var ragdoll_skeleton = $Mesh/Male/MaleSkeleton/Skeleton3D
@onready var bleed_out_timer = $bleed_out_timer

var physics_bones


# Called when the node enters the scene tree for the first time.
func _ready():
	if active_ragdoll_enabled == true:
		$bleed_out_timer.wait_time = randf_range(0.05,0.5)
		$bleed_out_timer.start()
	
	#ragdoll_skeleton.physical_bones_start_simulation()
	physics_bones = ragdoll_skeleton.get_children().filter(func(x): return x is PhysicalBone3D)
	#print(physics_bones)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ragdoll_health <= 0:
		var death_sounds = [load("res://assets/sounds/pawn_death/death6.wav"),
		load("res://assets/sounds/pawn_death/die1.wav"),
		load("res://assets/sounds/pawn_death/die2.wav"),
		load("res://assets/sounds/pawn_death/die3.wav")]

		if !death_sound_played:
			$bleed_out_death.pitch_scale = randf_range(0.9,1.5)
			if !$bleed_out_death.playing:
				$bleed_out_death.set_stream(death_sounds[randi_range(0,3)])
				$bleed_out_death.play()
				death_sound_played = true
	
	pass

func _physics_process(delta):
	if active_ragdoll_enabled == true:
		if linear_spring_stiffness <= 0:
			linear_spring_stiffness = 0
			ragdoll_health = 0
		
		if angular_spring_stiffness <= 0:
			angular_spring_stiffness = 0
			ragdoll_health = 0
			
		if max_angular_force <= 0:
			max_angular_force = 0
			ragdoll_health = 0
		
		if !target_skeleton == null:
			if !ragdoll_health <= 0:
				##Chest hit animation
				if bone_hit == 0 or bone_hit == 1 or bone_hit == 2:
					pawn_to_animate.anim_player.play("MaleAnimations/WritheChestBack")
				
				##Right knee hit animation
				if bone_hit == 48 or bone_hit == 49  or bone_hit == 50:
					pawn_to_animate.anim_player.play("MaleAnimations/WritheRightKneeBack")
					
				##Head = Insta kill
				if bone_hit == 41 or bone_hit == 42:
					ragdoll_health = 0
				
				for b in physics_bones:
						if !b.name == "Physical Bone Spine_2" and !b.name == "Physical Bone Neck" and !b.name == "Physical Bone Spine_1" and !b.name == "Physical Bone Spine_0":
							var target_transform: Transform3D = target_skeleton.global_transform * target_skeleton.get_bone_global_pose(b.get_bone_id())
							var current_transform: Transform3D = ragdoll_skeleton.global_transform * ragdoll_skeleton.get_bone_global_pose(b.get_bone_id())
							var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())
						
							var position_difference:Vector3 = target_transform.origin - current_transform.origin
							
							var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, angular_spring_stiffness, angular_spring_damping)
							torque = torque.limit_length(max_angular_force)
							
							b.angular_velocity += torque * delta

func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)


func _on_bleed_out_timer_timeout() -> void:
	if !ragdoll_health == 0:
		ragdoll_health = ragdoll_health - 1
		$bleed_out_timer.start()
	if ragdoll_health == 0:
		$bleed_out_timer.stop()
		pawn_dead.queue_free()



func _on_slow_remove_timeout():
	var amount  = randi_range(45,360)
	linear_spring_stiffness = linear_spring_stiffness - 25 - amount
	angular_spring_stiffness = angular_spring_stiffness - 25 - amount
	max_angular_force = max_angular_force - 25 - amount
	$slow_remove.start()
