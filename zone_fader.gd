extends Node

@export var layer_groups: Array[Node2D]   # SkyGroup, FarGroup, MidGroup, NearGroup
@export var level_left := -1500.0         # ujung kiri lantai
@export var zone_width := 600.0           # lebar tiap zona
@export var blend := 150.0                # lebar transisi (makin besar makin halus)

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var cx := cam.get_screen_center_position().x
	for group in layer_groups:
		var count := group.get_child_count()
		for z in count:
			var layer := group.get_child(z) as CanvasItem
			if layer == null:
				continue
			var a := _coverage(z, count, cx)
			layer.modulate.a = a
			layer.visible = a > 0.01

func _coverage(z: int, count: int, cx: float) -> float:
	var left := level_left + z * zone_width
	var right := left + zone_width
	var fade_in := 1.0
	var fade_out := 1.0
	if z > 0:
		fade_in = smoothstep(left - blend, left + blend, cx)
	if z < count - 1:
		fade_out = 1.0 - smoothstep(right - blend, right + blend, cx)
	return minf(fade_in, fade_out)
