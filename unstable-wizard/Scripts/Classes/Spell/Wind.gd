extends Area2D
class_name WindSpell

const EXPLOSION_SCENE = preload("res://Scenes/Spells/Explosion.tscn")

@export var speed: float = 500.0
@export var damage: int = 5
@export var max_distance: float = 1000.0
@export var pull_force: float = 600.0  # Increased from 300
@export var pull_radius: float = 120.0
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var has_ended := false
var is_vortex := false


func _ready() -> void:
	add_to_group("bullet")


func _physics_process(delta: float) -> void:
	if has_ended:
		return
	
	if not is_vortex:
		var travel_distance = minf(speed * delta, max_distance - distance_traveled)
		global_position += direction * travel_distance
		distance_traveled += travel_distance
		if distance_traveled >= max_distance:
			_activate_vortex()

	rotation += 0.2
	if is_vortex:
		pull_enemies(delta)


func _start_lifetime() -> void:
	await get_tree().create_timer(lifetime).timeout
	_finish()


func _activate_vortex() -> void:
	if is_vortex:
		return
	is_vortex = true
	_start_lifetime()


func pull_enemies(delta: float) -> void:
	# Get all enemies in pull radius
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		if distance_to_enemy < pull_radius and enemy.has_method("apply_wind_pull"):
			# Pull direction toward wind center
			var pull_direction = (global_position - enemy.global_position).normalized()
			if pull_direction != Vector2.ZERO:
				enemy.apply_wind_pull(pull_direction * pull_force * delta)


func _on_body_entered(body: Node2D) -> void:
	if has_ended:
		return
	if body.is_in_group("enemy"):
		body.damage_taken(damage)
		global_position = body.global_position
		_activate_vortex()
		return
	_finish(true)


func _finish(show_impact: bool = false) -> void:
	if has_ended:
		return
	has_ended = true
	if show_impact:
		var explosion = EXPLOSION_SCENE.instantiate()
		get_tree().current_scene.add_child(explosion)
		explosion.global_position = global_position
	queue_free()
