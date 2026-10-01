extends Area2D
class_name WindSpell

@export var speed: float = 500.0
@export var damage: int = 20
@export var max_distance: float = 1000.0
@export var pull_force: float = 600.0  # Increased from 300
@export var pull_radius: float = 400.0  # Increased from 250
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var has_ended := false


func _ready() -> void:
	add_to_group("bullet")
	await get_tree().create_timer(lifetime).timeout
	_finish()


func _physics_process(delta: float) -> void:
	if has_ended:
		return
	
	# Move like a solid projectile
	global_position += direction * speed * delta
	distance_traveled += speed * delta
	
	# Spin faster for visual effect
	rotation += 0.2
	
	# Strong pull towards center
	pull_enemies(delta)
	
	if distance_traveled >= max_distance:
		_finish()


func pull_enemies(delta: float) -> void:
	# Get all enemies in pull radius
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var distance_to_enemy = global_position.distance_to(enemy.global_position)
		
		if distance_to_enemy < pull_radius:
			# Pull direction toward wind center
			var pull_direction = (global_position - enemy.global_position).normalized()
			
			# Strong constant pull
			enemy.velocity += pull_direction * pull_force * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if has_ended:
		return
	if area.is_in_group("enemy"):
		var enemy = area.get_parent()
		if enemy and enemy.has_method("damage_taken"):
			enemy.damage_taken(damage)
		_finish()


func _finish() -> void:
	if has_ended:
		return
	has_ended = true
	queue_free()
