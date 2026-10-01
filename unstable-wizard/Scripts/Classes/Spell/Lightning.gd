extends Area2D
class_name Lightning

@export var damage: int = 50  # Big damage!
@export var range: float = 800.0
@export var width: float = 30.0
@export var lifetime: float = 0.15  # Quick flash

var direction: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO
var hit_enemies: Array = []


func _ready() -> void:
	add_to_group("bullet")
	
	# Calculate end position based on range
	end_position = global_position + direction * range
	
	# Draw the lightning beam
	queue_redraw()
	
	# Deal damage to enemies in the line
	deal_damage()
	
	# Disappear after a short time
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func deal_damage() -> void:
	# Get all enemies
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		
		# Check if enemy is on the lightning line
		var closest_point = get_closest_point_on_line(enemy.global_position)
		var distance_to_line = enemy.global_position.distance_to(closest_point)
		
		if distance_to_line <= width and not enemy in hit_enemies:
			hit_enemies.append(enemy)
			if enemy.has_method("damage_taken"):
				enemy.damage_taken(damage)


func get_closest_point_on_line(point: Vector2) -> Vector2:
	var start = global_position
	var end = end_position
	var line_vec = end - start
	var point_vec = point - start
	var line_len_sq = line_vec.length_squared()
	
	if line_len_sq == 0.0:
		return start
	
	var t = maxf(0.0, minf(1.0, point_vec.dot(line_vec) / line_len_sq))
	return start + line_vec * t


func _draw() -> void:
	# Draw a lightning bolt line
	draw_line(Vector2.ZERO, direction * range, Color.YELLOW, width)
	
	# Add some glow effect
	draw_line(Vector2.ZERO, direction * range, Color(1, 1, 0.5, 0.5), width * 2)
