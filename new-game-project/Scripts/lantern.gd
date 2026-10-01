extends StaticBody2D

@export var hanging = false
@export var flipped = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if hanging:
		$AnimatedSprite2D.play("hanging_lantern")
		$CollisionShape2D.set_deferred("disabled", true)
		self.set_scale(Vector2(2.5, 2.5))
	else:
		$AnimatedSprite2D.play("lantern")
	$AnimatedSprite2D.flip_h = flipped


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var value = _quadratic_bezier(Vector2(0,0.2),Vector2(0.5,0.6),Vector2(1,0.2), $Timer.get_time_left()/4).y
	$PointLight2D.set_energy(value)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
