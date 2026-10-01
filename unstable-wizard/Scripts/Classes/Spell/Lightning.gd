extends Area2D
class_name Lightning

@export var lifetime: float = 0.15  # Quick flash

var direction: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO
var hit_enemies: Array = []


func _ready() -> void:
	add_to_group("bullet")
	$AnimatedSprite2D.play("default")
	print("light")
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("damage_taken"):
		body.damage_taken(50)
