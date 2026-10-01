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

var movement_target_position: Vector2

@onready var nav: NavigationAgent2D = $NavigationAgent2D


func _ready():
	player = get_tree().root.get_node_or_null("main/player") as Node2D

	if enemy_name == "golem":
		$AnimatedSprite2D.play("golem_walk")
		health = 200
		damage = 20
		speed = randf_range(100, 120)
	elif enemy_name == "goblin":
		$AnimatedSprite2D.play("goblin_walk")
		$AnimatedSprite2D.scale = 0.25
		health = 100
		damage = 15
		speed = randf_range(150, 180)
	elif enemy_name == "knight":
		$AnimatedSprite2D.play("knight_walk")
		$AnimatedSprite2D.scale = 1
		health = 50
		damage = 10
		speed = randf_range(230, 260)
	
	$healthBar.set_max(health)
	$healthBar.value = health
	
	prev_speed = speed

func _physics_process(delta):
	if not is_instance_valid(player):
		return

	if not dead:
		speed = prev_speed
	
	if in_player:
		apply_knockback(250, player)
	
	#get the players pos and navigate towards it
	var direction = Vector3()
	player_pos = player.global_position
	nav.target_position = player_pos
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	#knockback
	knockback_force -= 50
	if knockback_force <= 0:
		knockback_force = 0
		knockback_active = false
	knockback = knockback_direction * knockback_force
	
	velocity = velocity.lerp(direction*speed, 10 * delta) + knockback
	move_and_slide()
	

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
		self.set_collision_mask_value(2, false)
		self.set_collision_mask_value(4, false)
		$Area2D.set_collision_layer_value(1, false)
		$Area2D.set_collision_layer_value(2, false)
		$Area2D.set_collision_layer_value(3, false)
		$Area2D.set_collision_layer_value(4, false)
		$healthBar.set_visible(false)
		$AnimatedSprite2D.play("death")
		
	#flicker the enemy sprite
	for i in 3:
		$AnimatedSprite2D.hide()
		await get_tree().create_timer(0.05).timeout
		$AnimatedSprite2D.show()
		await get_tree().create_timer(0.05).timeout

func apply_knockback(force, Player):
	if not knockback_active:
		knockback_force = force
		var rng = RandomNumberGenerator.new()
		var randomx = rng.randi_range(-10,10)
		var randomy = rng.randi_range(-10,10)
		knockback_direction = (global_position - Player.global_position).normalized() + Vector2(randomx,randomy).normalized()
		knockback = knockback_direction.normalized() * knockback_force
		knockback_active = true

#when the death animation finishes delete the enemy
# TODO rn it will delete itself after any animation finished. fix that.
func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		in_player = false
