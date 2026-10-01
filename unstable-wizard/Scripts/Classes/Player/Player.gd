extends CharacterBody2D
class_name Player

const FIREBALL_SCENE = preload("res://Scenes/Spells/fireball.tscn")
const WIND_SCENE = preload("res://Scenes/Spells/Wind.tscn")
const LIGHTNING_SCENE = preload("res://Scenes/Spells/lightning.tscn")


@export var speed: float = 250.0
@export var max_health: int = 100
@export var damage_cooldown: float = 0.8

var attacking: bool = false
var health: int
var damage_cooldown_remaining := 0.0
var dead := false

@onready var animation: AnimatedSprite2D = $anination
@onready var health_bar: ProgressBar = $HUD/HealthBar


func _ready() -> void:
	# Attack maar één keer afspelen
	animation.sprite_frames.set_animation_loop("attack", false)
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func _physics_process(delta: float) -> void:
	if dead:
		return
	damage_cooldown_remaining = maxf(damage_cooldown_remaining - delta, 0.0)

	var input_dir := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
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

func take_damage(amount: int) -> void:
	if dead or damage_cooldown_remaining > 0.0:
		return

	health = maxi(health - amount, 0)
	health_bar.value = health
	damage_cooldown_remaining = damage_cooldown
	if health == 0:
		dead = true
		velocity = Vector2.ZERO
		animation.play("idle")
		set_process_input(false)
		$anination/Camera2D/game_over.show()


func _input(event: InputEvent) -> void:
	if not dead and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not attacking:
				attack()


func attack() -> void:
	attacking = true
	animation.play("attack")
	
	# Randomly choose between fireball and wind
	var spell_choice = randi() % 2
	if spell_choice == 0:
		shoot_fireball()
	else:
		shoot_wind()

	await animation.animation_finished

	attacking = false


func shoot_fireball() -> void:
	var fireball = FIREBALL_SCENE.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	fireball.direction = global_position.direction_to(get_global_mouse_position())


func shoot_wind() -> void:
	var wind = WIND_SCENE.instantiate()
	get_tree().current_scene.add_child(wind)
	wind.global_position = global_position
	wind.direction = global_position.direction_to(get_global_mouse_position())

func shoot_lightning() -> void:
	var lightning = LIGHTNING_SCENE.instantiate()
	get_tree().current_scene.add_child(lightning)
	lightning.global_position = global_position
	lightning.direction = global_position.direction_to(get_global_mouse_position()).normalized()
