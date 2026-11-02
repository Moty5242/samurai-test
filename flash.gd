extends ColorRect

@export var bolt: Sprite2D
@export var bolt_textures: Array[Texture2D]
@export var min_wait := 4.0
@export var max_wait := 10.0

func _ready() -> void:
	color = Color(0.75, 0.85, 1.0, 0.0)
	if bolt:
		bolt.visible = false
	_loop()

func _loop() -> void:
	while true:
		await get_tree().create_timer(randf_range(min_wait, max_wait)).timeout
		await _strike()

func _strike() -> void:
	if bolt and bolt_textures.size() > 0:
		bolt.texture = bolt_textures.pick_random()
		bolt.position.x = randf_range(-288.0, 100.0)
		bolt.visible = true
		get_tree().create_timer(0.3).timeout.connect(func(): bolt.visible = false)

	var t := create_tween()
	t.tween_property(self, "color:a", 0.55, 0.04)
	t.tween_property(self, "color:a", 0.10, 0.06)
	t.tween_property(self, "color:a", 0.80, 0.04)
	t.tween_property(self, "color:a", 0.00, 0.50)
	await t.finished
