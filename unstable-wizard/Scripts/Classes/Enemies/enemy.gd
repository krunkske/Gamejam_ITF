extends CharacterBody2D

var player: Node2D
@export var enemy_name :String
var player_pos

var health = 60
var speed = 190
var prev_speed = speed
var damage = 20
var dead = false
var in_player = false

var knockback_active = false
var knockback_force = 500
var knockback_direction = Vector2()
var knockback = Vector2()
var wind_pull_velocity := Vector2.ZERO

var movement_target_position: Vector2

@onready var nav: NavigationAgent2D = $NavigationAgent2D


func _ready():
	add_to_group("enemy")
	player = get_tree().root.get_node_or_null("main/player") as Node2D

	if enemy_name == "golem":
		$AnimatedSprite2D.play("golem_walk")
		health = 150
		damage = 20
		speed = randf_range(100, 120)
	elif enemy_name == "goblin":
		$AnimatedSprite2D.play("goblin_walk")
		health = 100
		damage = 15
		speed = randf_range(130, 150)
	elif enemy_name == "knight":
		$AnimatedSprite2D.play("knight_walk")
		health = 50
		damage = 10
		speed = randf_range(170, 200)
	
	$healthBar.set_max(health)
	$healthBar.value = health
	
	prev_speed = speed

func _physics_process(delta):
	if not is_instance_valid(player):
		return
	if dead:
		velocity = Vector2.ZERO
		return

	speed = prev_speed
	
	if in_player:
		apply_knockback(250, player)
	
	#get the players pos and navigate towards it
	var direction = Vector2()
	player_pos = player.global_position
	nav.target_position = player_pos
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	#knockback
	if knockback_active:
		knockback_force = move_toward(knockback_force, 0.0, 900.0 * delta)
		knockback = knockback_direction * knockback_force
	if knockback_force <= 0:
		knockback_force = 0
		knockback_active = false
		knockback = Vector2.ZERO
	
	wind_pull_velocity = wind_pull_velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	velocity = velocity.lerp(direction*speed, 10 * delta) + knockback + wind_pull_velocity
	move_and_slide()
	for collision_index in get_slide_collision_count():
		if get_slide_collision(collision_index).get_collider() == player:
			player.take_damage(damage)
			break
	

	$AnimatedSprite2D.play()
	
	#flip the texture so were facing the player
	if position.x > player_pos.x:
		$AnimatedSprite2D.flip_h = true
	elif position.x < player_pos.x:
		$AnimatedSprite2D.flip_h = false

func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet") and not dead:
		apply_knockback(200,area)
		damage_taken(area.damage)
	elif area.is_in_group("coin"):
		pass
	if area.is_in_group("player") and not dead:
		in_player = true

func damage_taken(Damage):
	health = health - Damage
	$healthBar.value = health
	if health <= 0 and not dead:
		dead = true
		speed = 0
		#disable all colission and play death animation
		self.set_collision_layer_value(3, false)
		self.set_collision_mask_value(1, false)
		self.set_collision_mask_value(2, false)
		self.set_collision_mask_value(3, false)
		#$Area2D.set_collision_layer_value(1, false)
		#$Area2D.set_collision_layer_value(2, false)
		#$Area2D.set_collision_layer_value(3, false)
		#$Area2D.set_collision_layer_value(4, false)
		$healthBar.set_visible(false)
		$AnimatedSprite2D.play("death")
		$Timer.start()
		
	#flicker the enemy sprite
	for i in 3:
		$AnimatedSprite2D.hide()
		await get_tree().create_timer(0.05).timeout
		$AnimatedSprite2D.show()
		await get_tree().create_timer(0.05).timeout

func apply_knockback(force: float, source: Node2D) -> void:
	if knockback_active or dead:
		return

	knockback_force = force
	knockback_direction = (global_position - source.global_position).normalized()
	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.RIGHT
	knockback_active = true


func apply_wind_pull(force: Vector2) -> void:
	if not dead:
		wind_pull_velocity = (wind_pull_velocity + force).limit_length(500.0)


func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		in_player = false


func _on_timer_timeout() -> void:
	queue_free()
