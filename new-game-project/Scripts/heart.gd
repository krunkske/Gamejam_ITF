extends Area2D

@export var Aname = "heart"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")
	$Timer.start()
	$flicker_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area.is_in_group("player"):
		queue_free()

func _on_timer_timeout():
	queue_free()

func _on_flicker_timer_timeout():
	for i in 15:
		$AnimatedSprite2D.hide()
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.show()
		await get_tree().create_timer(0.1).timeout
