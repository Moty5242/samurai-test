extends Node2D

@export var player: Node2D
@export var left_glow: Sprite2D
@export var right_glow: Sprite2D
@export var left_x := -1500.0
@export var right_x := 1500.0
@export var show_distance := 220.0   # mulai terlihat pada jarak ini
@export var pulse_speed := 4.0       # kecepatan denyut cahaya

func _process(_delta: float) -> void:
	if player == null:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var pulse := 0.85 + 0.15 * sin(t * pulse_speed)
	left_glow.modulate.a = _fade(player.global_position.x - left_x) * pulse
	right_glow.modulate.a = _fade(right_x - player.global_position.x) * pulse

func _fade(dist: float) -> float:
	return clampf(1.0 - dist / show_distance, 0.0, 1.0)
