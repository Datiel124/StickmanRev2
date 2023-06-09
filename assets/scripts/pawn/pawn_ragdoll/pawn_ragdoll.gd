
extends Node3D
class_name Ragdoll

var ragdoll_health = 15
var bone_hit = 0
var pawn_to_animate : CharacterBody3D
var death_sound_played = false

@onready var pawnBody = $Mesh/Male/MaleSkeleton/Skeleton3D/MaleBody
@onready var pawnHead = $Mesh/Male/MaleSkeleton/Skeleton3D/MaleHead

@onready var remove_timer = $remove_timer
@export var pawn_dead:Pawn_Controller

@export var active_ragdoll_enabled : bool
@export var target_skeleton: Skeleton3D

@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

@onready var body = $Mesh
@onready var ragdoll_skeleton : Skeleton3D = $Mesh/Male/MaleSkeleton/Skeleton3D

var physics_bones


# Called when the node enters the scene tree for the first time.
func _ready():
	#ragdoll_skeleton.physical_bones_start_simulation()
	Global.num_ragdolls += 1
	physics_bones = ragdoll_skeleton.get_children().filter(func(x): return x is PhysicalBone3D)
	pawnBody.set_surface_override_material(0, pawn_dead.character_pawn.pawnMat)
	pawnHead.set_surface_override_material(0, pawn_dead.character_pawn.pawnMat)
	#print(physics_bones)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)


func _on_remove_timer_timeout():
	queue_free()


func _exit_tree() -> void:
	Global.num_ragdolls -= 1
