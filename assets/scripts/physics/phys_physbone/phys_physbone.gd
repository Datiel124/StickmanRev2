extends PhysicalBone3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func damage(amount, impulseMult:int = 0, bulletDir:Vector3 = Vector3.ZERO, hitPos : Vector3 = Vector3.ZERO, applyKnockback:bool = false, knockbackAmount:int = 0):
	var localPoint = self.to_local(hitPos)
	var physOffset = localPoint - self.position
	physOffset = self.to_global(physOffset)
	var totalForce = -(bulletDir.normalized()) + (Vector3.UP)
	GlobalParticles.create_blood(0,hitPos)
	
	self.apply_impulse(totalForce, hitPos)
