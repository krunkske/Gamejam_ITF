extends Area2D

@export var speed: float = 500.0
@export var damage: int = 25
@export var lifetime: float = 3.0

var direction: Vector2


func _ready() -> void:
	add_to_group("bullet")
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("damage_taken"):
		body.damage_taken(damage)
	queue_free()
