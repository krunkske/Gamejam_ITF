extends Area2D

@export var bullet_speed = 750
@export var texture = ""
@export var active = true
@export var damage = 20
const jsonGunPath = "res://Assets/json/guns.json"
var gunData

func _ready():
	#load the json data
	var json_as_text = FileAccess.get_file_as_string(jsonGunPath)
	gunData = JSON.parse_string(json_as_text)
	
	gunData = gunData[texture]
	damage = gunData.damage
	$AnimatedSprite2D.play(texture)
	
	if texture == "grape":
		$hitbox.shape.set_radius(4)
		$AnimatedSprite2D.set_scale(Vector2(1.5,1.5))

func _physics_process(delta):
	if load.playing:
		position += transform.x * bullet_speed * delta
		$AnimatedSprite2D.rotation += 0.5

func _on_body_entered(body):
	self.set_collision_mask_value(2, false)
	self.set_collision_mask_value(3, false)
	self.set_collision_layer_value(4, false)
	$AnimatedSprite2D.visible = false
	if texture == "banana":
		$banana_particle.restart()
	elif texture == "apple":
		$apple_particle.restart()
	elif texture == "grape":
		$grape_particle.restart()

func _on_banana_particle_finished():
	queue_free()

func _on_apple_particle_finished():
	queue_free()

func _on_grape_particle_finished():
	queue_free()
