extends CharacterBody2D
class_name Player

@export var speed: float = 250.0
@export var fire_rate: float = 0.3
@export var spell_scene: PackedScene

var can_shoot: bool = true

@onready var spell_spawn: Marker2D = $SpellSpawn

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	velocity = input_dir.normalized() * speed
	move_and_slide()

	# Walk animatie alleen tijdens bewegen
	if input_dir != Vector2.ZERO:
		$anination.play("walk")
	else:
		$anination.stop()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and can_shoot:
		shoot()


func shoot() -> void:
	if spell_scene == null:
		push_warning("Geen spell_scene toegewezen aan Player!")
		return

	can_shoot = false

	var spell := spell_scene.instantiate()
	get_tree().current_scene.add_child(spell)
	spell.global_position = spell_spawn.global_position

	# Richting naar muis
	var dir := (
		get_global_mouse_position() - spell_spawn.global_position
	).normalized()

	if "direction" in spell:
		spell.direction = dir

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
