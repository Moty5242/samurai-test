extends Node2D

@export_dir var folder := "res://Asset/background/zones"
@export var zone_count := 5
@export var level_left := -1500.0
@export var zone_width := 600.0
@export var blend := 150.0                       # lebar transisi antar zona
@export var image_width := 576.0
@export var image_pos := Vector2(-288, -480)
@export var bolt_y := -280.0

const LAYERS := ["sky", "far", "mid", "near"]
const SCROLL := [0.05, 0.2, 0.5, 0.85]

var bolt: Sprite2D                               # dipakai skrip kilat
var _sprites: Array = []                         # [zona][lapisan]

func _ready() -> void:
	for z in zone_count:
		_sprites.append([])
	for li in LAYERS.size():
		for z in zone_count:
			var p := Parallax2D.new()
			p.scroll_scale = Vector2(SCROLL[li], 1.0)
			p.repeat_size = Vector2(image_width, 0.0)
			p.repeat_times = 3
			add_child(p)
			var s := Sprite2D.new()
			s.centered = false
			s.position = image_pos
			var path := "%s/zone%d_%s.png" % [folder, z + 1, LAYERS[li]]
			if ResourceLoader.exists(path):
				s.texture = load(path)
			else:
				push_warning("Gambar tidak ditemukan: " + path)
			p.add_child(s)
			_sprites[z].append(s)
		if li == 0:                              # petir: di atas langit, di bawah gunung
			var bp := Parallax2D.new()
			bp.scroll_scale = Vector2(SCROLL[0], 1.0)
			add_child(bp)
			bolt = Sprite2D.new()
			bolt.centered = false
			bolt.position = Vector2(-288.0, bolt_y)
			bolt.visible = false
			bp.add_child(bolt)

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var cx := cam.get_screen_center_position().x
	for z in zone_count:
		var a := _coverage(z, cx)
		for s in _sprites[z]:
			s.modulate.a = a
			s.visible = a > 0.01

func _coverage(z: int, cx: float) -> float:
	var left := level_left + z * zone_width
	var right := left + zone_width
	var fade_in := 1.0
	var fade_out := 1.0
	if z > 0:
		fade_in = smoothstep(left - blend, left + blend, cx)
	if z < zone_count - 1:
		fade_out = 1.0 - smoothstep(right - blend, right + blend, cx)
	return minf(fade_in, fade_out)
