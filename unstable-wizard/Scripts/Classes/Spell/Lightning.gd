extends Area2D
class_name Lightning

@export var lifetime: float = 0.15  # Quick flash
@export var damage: int = 50

var direction: Vector2 = Vector2.ZERO
var hit_enemies: Array = []


func _ready() -> void:
	add_to_group("bullet")
	$AnimatedSprite2D.play("default")
	_process_mouse_aim()
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _process(_delta: float) -> void:
	_process_mouse_aim()


func _process_mouse_aim() -> void:
	direction = global_position.direction_to(get_global_mouse_position())
	if direction != Vector2.ZERO:
		rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not hit_enemies.has(body):
		hit_enemies.append(body)
		if body.has_method("damage_taken"):
			body.damage_taken(damage)
