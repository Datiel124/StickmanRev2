extends Panel

@export var y_scale_mult : float = 0.0
@onready var target_min_y = custom_minimum_size.y
@onready var timer = $Timer


func fit_children() -> Vector2:
	#get all the children, figure out sizemost on both axis
	var sizemost : Vector2 = Vector2.ZERO
	for i in get_children().filter(func(child): return child is Control):
		if i is Button:
			continue
		sizemost.x = max(sizemost.x, i.position.x + i.size.x)
		sizemost.y = max(sizemost.y, i.position.y + i.size.y)
	target_min_y = sizemost.y
	return sizemost


func _process(delta: float) -> void:
	custom_minimum_size.x = fit_children().x + 8
	custom_minimum_size.y = target_min_y * y_scale_mult
	size = custom_minimum_size


func set_text(text : String) -> void:
	$Label.text = text


func set_warn_params(texture, fade_time : float = -1) -> void:
	if not has_node("Label/TextureRect"):return
	$Label/TextureRect.texture = texture
	if fade_time > 0:
		$Timer.start(fade_time)


func set_click_params(call_on_click : Callable, binds : Array = [], fade_time : float = -1) -> void:
	if not has_node("Button"):return
	$Button.pressed.connect(call_on_click.bindv(binds))
	if fade_time > 0:
		$Timer.start(fade_time)


func _on_timer_timeout() -> void:
	while modulate.a > 0:
		modulate.a -= get_process_delta_time()
		await get_tree().process_frame
	while y_scale_mult > 0:
		y_scale_mult -= get_process_delta_time() * 2
		await get_tree().process_frame
	queue_free()
	pass # Replace with function body.


func _on_button_pressed() -> void:
	$Button.disabled = true
	$Timer.paused = true
	while modulate.a > 0:
		modulate.a -= get_process_delta_time() * 5
		await get_tree().process_frame
	while y_scale_mult > 0:
		y_scale_mult -= get_process_delta_time() * 10
		await get_tree().process_frame
	queue_free()
	pass # Replace with function body.
