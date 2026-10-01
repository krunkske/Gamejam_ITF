extends Area2D

@export var speed: float = 500.0
@export var damage: int = 25

var direction: Vector2


func _physics_process(delta):
	position += direction * speed * delta
