extends Area2D

@export var speed: float = 500.0
@export var damage: int = 25
@export var lifetime: float = 3.0

var direction: Vector2


func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		explode()


func explode():
	for enemy in $ExplosionArea.get_overlapping_bodies():
		if enemy.is_in_group("enemies"):
			enemy.take_damage(damage)

	queue_free()
