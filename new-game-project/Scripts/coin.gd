extends Area2D

var value = 100
var touched = false
@onready var playerNode = load.player
# Called when the node enters the scene tree for the first time.
func _ready():
	if value == 50:
		$AnimatedSprite2D.play("small_coin")
	elif value == 100:
		$AnimatedSprite2D.play("medium_coin")
	elif value == 200:
		$AnimatedSprite2D.play("large_coin")
	$Timer.start()
	$flicker_timer.start()
	$Area2D/CollisionShape2D.get_shape().set_radius(load.radius)

func _process(delta):
	var velocity = Vector2.ZERO
	if touched:
		var direction = (playerNode.global_position - global_position).normalized()
		velocity = direction * 1000 * delta # Adjust 1000 to control speed
		global_position += velocity

func _on_area_entered(area):
	if area.is_in_group("player"):
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_flicker_timer_timeout():
	for i in 20:
		$AnimatedSprite2D.hide()
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.show()
		await get_tree().create_timer(0.1).timeout

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		touched = true
