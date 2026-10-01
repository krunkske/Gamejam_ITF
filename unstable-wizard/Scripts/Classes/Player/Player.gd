extends CharacterBody2D
class_name Player

const FIREBALL_SCENE = preload("res://Scenes/Spells/fireball.tscn")

@export var speed: float = 250.0

var attacking: bool = false

@onready var animation: AnimatedSprite2D = $anination


func _ready() -> void:
	# Attack maar één keer afspelen
	animation.sprite_frames.set_animation_loop("attack", false)


func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# Beweging
	velocity = input_dir.normalized() * speed
	move_and_slide()
	_push_colliding_enemies()

	# Karakter omdraaien
	if input_dir.x < 0:
		animation.flip_h = true
	elif input_dir.x > 0:
		animation.flip_h = false

	# Tijdens attack niets veranderen
	if attacking:
		return

	# Bewegen = walk
	if input_dir != Vector2.ZERO:
		if animation.animation != "walk":
			animation.play("walk")

	# Stilstaan = idle
	else:
		if animation.animation != "idle":
			animation.play("idle")

func _push_colliding_enemies() -> void:
	for collision_index in get_slide_collision_count():
		var collider = get_slide_collision(collision_index).get_collider()
		if collider is CharacterBody2D and collider.has_method("apply_knockback"):
			collider.apply_knockback(250.0, self)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not attacking:
				attack()


func attack() -> void:
	attacking = true
	animation.play("attack")
	shoot_fireball()

	await animation.animation_finished

	attacking = false


func shoot_fireball() -> void:
	var fireball = FIREBALL_SCENE.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	fireball.direction = global_position.direction_to(get_global_mouse_position())
