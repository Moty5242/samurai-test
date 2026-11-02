extends Node2D

@export var rain_texture: Texture2D      # rain_drop.png
@export var splash_texture: Texture2D    # splash_drop.png
@export var floor_y := -20.0             # permukaan lantai
@export var top_y := -380.0              # tinggi tetes mulai jatuh
@export var half_width := 380.0
@export var drop_count := 330
@export var speed_min := 450.0
@export var speed_max := 560.0
@export var slant := -0.15               # negatif = miring ke kiri
@export var splash_chance := 0.35        # peluang tetes jadi percikan
@export var splash_gravity := 700.0

class Splash:
	var pos: Vector2
	var vel: Vector2
	var age := 0.0
	var life := 0.25

# tiap tetes: x = jarak dari tengah kamera, y = tinggi dunia, z = kecepatan jatuh
var _drops: Array[Vector3] = []
var _splashes: Array[Splash] = []
var _cx := 0.0

func _ready() -> void:
	_cx = _cam_x()
	for i in drop_count:
		_drops.append(_new_drop(true))

func _cam_x() -> float:
	var cam := get_viewport().get_camera_2d()
	return cam.get_screen_center_position().x if cam else 0.0

func _new_drop(random_height: bool) -> Vector3:
	var off := 30.0 + randf_range(-half_width, half_width)
	var y := randf_range(top_y, floor_y) if random_height else top_y - randf() * 40.0
	return Vector3(off, y, randf_range(speed_min, speed_max))

func _spawn_splash(world_x: float) -> void:
	for i in randi_range(2, 3):
		var s := Splash.new()
		s.pos = Vector2(world_x, floor_y)
		s.vel = Vector2(randf_range(-45.0, 45.0), randf_range(-85.0, -35.0))
		s.life = randf_range(0.18, 0.3)
		_splashes.append(s)

func _process(delta: float) -> void:
	_cx = _cam_x()
	for i in _drops.size():
		var d := _drops[i]
		d.x += slant * d.z * delta       # kemiringan tetap, tidak terpengaruh kamera
		d.y += d.z * delta
		if d.y >= floor_y:
			if randf() < splash_chance:
				_spawn_splash(_cx + d.x)
			d = _new_drop(false)
		elif d.x < -half_width - 100.0:
			d = _new_drop(false)
		_drops[i] = d

	for i in range(_splashes.size() - 1, -1, -1):
		var s := _splashes[i]
		s.age += delta
		s.vel.y += splash_gravity * delta
		s.pos += s.vel * delta
		if s.pos.y >= floor_y or s.age >= s.life:
			_splashes.remove_at(i)

	queue_redraw()

func _draw() -> void:
	if rain_texture:
		var sz := rain_texture.get_size()
		for d in _drops:
			draw_texture(rain_texture, Vector2(_cx + d.x - sz.x * 0.5, d.y - sz.y))
	if splash_texture:
		for s in _splashes:
			var a := 1.0 - s.age / s.life
			draw_texture(splash_texture, s.pos - Vector2(1, 1), Color(1, 1, 1, a))
