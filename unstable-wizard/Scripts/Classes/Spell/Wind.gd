extends Area2D
class_name WindSpell

@export var speed: float = 400.0
@export var damage: int = 15
@export var max_distance: float = 800.0
@export var pull_force: float = 300.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0


func _ready() -> void:
	add_to_group("bullet")
	# Draw a simple circle visual
	var circle = CircleShape2D.new()
	circle.radius = 40
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	distance_traveled += speed * delta
	
	# Spin for tornado effect
	rotation += 0.15
	
	pull_enemies(delta)
	
	if distance_traveled >= max_distance:
		queue_free()


func pull_enemies(delta: float) -> void:
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemy"):
			var enemy = area.get_parent()
			if enemy:
				var pull_direction = (global_position - enemy.global_position).normalized()
				enemy.velocity += pull_direction * pull_force * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.get_parent().has_method("damage_taken"):
		area.get_parent().damage_taken(damage)
