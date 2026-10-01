extends Area2D

const EXPLOSION_SCENE = preload("res://Scenes/Spells/Explosion.tscn")

@export var speed: float = 500.0
@export var damage: int = 25
@export var lifetime: float = 3.0

var direction: Vector2
var has_ended := false


func _ready() -> void:
	add_to_group("bullet")
	await get_tree().create_timer(lifetime).timeout
	_finish()



func _physics_process(delta: float) -> void:
	if has_ended:
		return
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if has_ended:
		return
	if body.has_method("damage_taken"):
		body.damage_taken(damage)
	_finish()

func _finish() -> void:
	if has_ended:
		return
	has_ended = true
	var explosion = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	queue_free()
