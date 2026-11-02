extends CharacterBody2D

const WALK_SPEED := 120.0
const RUN_SPEED := 220.0
const JUMP_VELOCITY := -380.0
const ATTACK_LUNGE := 90.0       # dorongan kecil ke depan saat menebas
const MAX_COMBO := 3
const COMBO_WINDOW := 0.25       # detik setelah serangan selesai untuk lanjut combo

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing := 1.0
var is_attacking := false
var is_blocking := false         # bisa dipakai musuh nanti untuk cek apakah serangan ditangkis
var combo_step := 0
var combo_queued := false
var combo_window := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	_handle_combat_input(delta)

	var dir := Input.get_axis("move_left", "move_right")
	var running := Input.is_action_pressed("run")

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	elif is_blocking:
		velocity.x = 0.0
	else:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = dir * (RUN_SPEED if running else WALK_SPEED)
		if dir != 0.0:
			facing = signf(dir)

	move_and_slide()
	_update_animation(dir, running)

func _handle_combat_input(delta: float) -> void:
	# proteksi: tahan klik kanan
	is_blocking = Input.is_action_pressed("guard") and is_on_floor() and not is_attacking

	# serangan: klik kiri
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_blocking:
		if is_attacking:
			if combo_step < MAX_COMBO:
				combo_queued = true
		elif combo_window > 0.0 and combo_step < MAX_COMBO:
			_start_attack(combo_step + 1)
		else:
			_start_attack(1)

	# jendela combo habis -> reset
	if combo_window > 0.0 and not is_attacking:
		combo_window -= delta
		if combo_window <= 0.0:
			combo_step = 0

func _start_attack(step: int) -> void:
	is_attacking = true
	combo_step = step
	combo_queued = false
	combo_window = 0.0
	var d := Input.get_axis("move_left", "move_right")
	if d != 0.0:
		facing = signf(d)
	sprite.flip_h = facing < 0.0
	velocity.x = facing * ATTACK_LUNGE
	sprite.play("attack_%d" % step)

func _on_animation_finished() -> void:
	if not is_attacking:
		return
	if combo_queued and combo_step < MAX_COMBO:
		_start_attack(combo_step + 1)
	else:
		is_attacking = false
		combo_queued = false
		combo_window = COMBO_WINDOW

func _update_animation(dir: float, running: bool) -> void:
	if is_attacking:
		return
	if is_blocking:
		sprite.flip_h = facing < 0.0
		if sprite.animation != "protect":
			sprite.play("protect")
		return
	if dir != 0.0:
		sprite.flip_h = dir < 0.0
	if not is_on_floor():
		sprite.play("jump")
	elif dir == 0.0:
		sprite.play("idle")
	elif running:
		sprite.play("run")
	else:
		sprite.play("walk")
