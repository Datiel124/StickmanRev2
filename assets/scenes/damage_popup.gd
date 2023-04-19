extends Label3D


@export var color_gradient : GradientTexture1D
var accumulated_damage : float = 0.0:
	set(value):
		if is_inside_tree():
			$Timer.start(0.5)
		if fall_down:
			return
		cool_effect(value)
		modulate = color_gradient.get_image().get_pixel(clamp(accumulated_damage/3.9, 0, 255), 0)
		text = str("%1.0f" % value)
		accumulated_damage = value

@onready var tweener = get_tree().create_tween().bind_node(self)
func cool_effect(values) -> void:
	while !is_inside_tree():
		await ready
	tweener.kill()
	pixel_size *= 1.2
	tweener = create_tween()

	tweener.set_ease(Tween.EASE_OUT)
	tweener.set_trans(Tween.TRANS_ELASTIC)

	var scalefactor = (pow(values, 0.5) / 2000 + 0.002)
	tweener.tween_property(self, "pixel_size", scalefactor, 0.5)


func _ready() -> void:
	$Timer.start(0.5)


var velocity : Vector3 = Vector3.ZERO
var fall_down := false
func _process(delta: float) -> void:
	if !fall_down:
		return
	position += velocity * delta
	pixel_size -= delta * 0.01
	velocity.y -= delta * 6
	if pixel_size < 0.0002:
		queue_free()


func start_falling() -> void:
	fall_down = true
	$Timer.stop()
	velocity.y = randf_range(2,4)
	velocity.x = randf_range(-2, 2)
	velocity.z = randf_range(-2, 2)


func _on_timer_timeout() -> void:
	if !fall_down:
		start_falling()
	pass # Replace with function body.
