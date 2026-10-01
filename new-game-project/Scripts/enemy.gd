extends CharacterBody2D

@onready var player = load.player
@export var enemy_name :String
const heartPath = preload("res://Scenes/heart.tscn")
const coinPath = preload("res://Scenes/coin.tscn")
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
	if enemy_name == "medium_ksander":
		$AnimatedSprite2D.play("walk_1")
		health = 100 * load.enemyHealthMultiplier
		damage = 20
		speed = randf_range(150, 180) * load.enemySpeedMultipler
	elif enemy_name == "medium_stef":
		$AnimatedSprite2D.play("walk_2")
		health = 100 * load.enemyHealthMultiplier
		damage = 15
		speed = randf_range(150, 180) * load.enemySpeedMultipler
	elif enemy_name == "speedy_bart":
		$AnimatedSprite2D.play("walk_3")
		health = 50 * load.enemyHealthMultiplier
		damage = 10
		speed = randf_range(230, 260) * load.enemySpeedMultipler
	elif enemy_name == "big_dante":
		self.set_scale(Vector2(1.25,1.25))
		$AnimatedSprite2D.play("walk_4")
		health = 200 * load.enemyHealthMultiplier
		damage = 30
		speed = randf_range(120, 150) * load.enemySpeedMultipler
	
	$healthBar.set_max(health)
	$healthBar.value = health
	
	prev_speed = speed

func _physics_process(delta):
	if not load.playing:
		speed = 0
	elif not dead:
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
	
	if not load.playing:
		$AnimatedSprite2D.pause()
	else:
		$AnimatedSprite2D.play()
	
	#flip the texture so were facing the player
	if position.x > player_pos.x:
		$AnimatedSprite2D.flip_h = false
	elif position.x < player_pos.x:
		$AnimatedSprite2D.flip_h = true

func _on_area_2d_area_entered(area):
	if area.is_in_group("bullet") and not dead:
		apply_knockback(200,area)
		damage_taken(area.damage * load.damageMultiplier)
	elif area.is_in_group("dog") and not dead:
		apply_knockback(200,area)
		damage_taken(area.get_parent().damage)
	elif area.is_in_group("player") and not dead or area.is_in_group("enemies") and not dead:
		if load.dashing:
			apply_knockback(400, area)
			damage_taken(25)
	elif area.is_in_group("coin"):
		pass
	#else:
		#apply_knockback(300, area)
	if area.is_in_group("player") and not dead:
		in_player = true

func damage_taken(Damage):
	health = health - (Damage * load.damageMultiplier)
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
		if enemy_name == "meduim_ksander":
			$AnimatedSprite2D.play("death_1")
		elif enemy_name == "medium_stef":
			$AnimatedSprite2D.play("death_2")
		elif enemy_name == "speedy_bart":
			$AnimatedSprite2D.play("death_3")
		elif enemy_name == "big_dante":
			$AnimatedSprite2D.play("death_4")
		else:
			$AnimatedSprite2D.play("death_1")
		#add score
		if enemy_name == "medium_ksander":
			load.score = load.score + 50
		elif enemy_name == "medium_stef":
			load.score = load.score + 75
		elif enemy_name == "speedy_bart":
			load.score = load.score + 75
		elif enemy_name == "big_dante":
			load.score = load.score + 200
		
		#random chance of heart spawning
		var rng = RandomNumberGenerator.new()
		var chance = rng.randi_range(0,50)
		if chance == 0:
			var heart = heartPath.instantiate()
			heart.global_position = global_position
			call_deferred("add_sibling", heart)
		elif chance >= 10:
			var coinvalue
			if enemy_name == "medium_ksander" or enemy_name == "medium_stef" or enemy_name == "speedy_bart":
				coinvalue = 100
			elif enemy_name == "big_dante":
				coinvalue = 200
			else:
				coinvalue = 0
			var coin = coinPath.instantiate()
			coin.global_position = global_position
			coin.value = coinvalue
			call_deferred("add_sibling", coin)
		
		load.latestDead = self
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
	if $AnimatedSprite2D.get_animation() == "death_1" or $AnimatedSprite2D.get_animation() == "death_2" or $AnimatedSprite2D.get_animation() == "death_3" or $AnimatedSprite2D.get_animation() == "death_4":
		queue_free()

func _on_area_2d_area_exited(area):
	if area.is_in_group("player"):
		in_player = false
