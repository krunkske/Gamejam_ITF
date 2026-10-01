extends CharacterBody2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D

@onready var player = load.player
var target = null
var currentEnemy = null
var distance_to_enemy = 0
var enemies_in_area = []
var speed = 200
@export var damage = 20


var knockback_active = false
var knockback_force = 500
var knockback_direction = Vector2()
var knockback = Vector2()

func _ready():
	$AnimatedSprite2D.play("walk")
	target = player

func _physics_process(delta):
	if load.dogActive:
		#get a new enemy when the old one died
		if load.latestDead == currentEnemy:
			target = get_next_enemy()
			currentEnemy = target
		
		var direction = Vector3()
		var enemy_pos = target.global_position
		nav.target_position = enemy_pos
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		knockback_force -= 50
		if knockback_force <= 0:
			knockback_force = 0
			knockback_active = false
		knockback = knockback_direction * knockback_force
		velocity = velocity.lerp(direction*speed, 10 * delta) + knockback
		move_and_slide()
		
		if position.x > enemy_pos.x:
			$AnimatedSprite2D.flip_h = true
		elif position.x < enemy_pos.x:
			$AnimatedSprite2D.flip_h = false

func get_next_enemy():
	var closest_enemy
	var closest_distance = INF
	
	if enemies_in_area == []:
		return player
	
	for Enemy in enemies_in_area:
		var enemy_position = Enemy.global_position
		var distance = global_position.distance_to(enemy_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = Enemy
	if closest_enemy:
		distance_to_enemy = closest_distance
		return closest_enemy
	else:
		#print("No enemies found in the 'enemies' group.")
		return player

func apply_knockback(force, Player):
	if not knockback_active:
		knockback_force = force
		var rng = RandomNumberGenerator.new()
		var randomx = rng.randi_range(-10,10)
		var randomy = rng.randi_range(-10,10)
		knockback_direction = (global_position - Player.global_position).normalized() + Vector2(randomx,randomy).normalized()
		knockback = knockback_direction.normalized() * knockback_force
		knockback_active = true

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemies"):
		apply_knockback(300, area)

func _on_radius_area_entered(area):
	if area.is_in_group("enemies"):
		enemies_in_area.append(area.get_parent())
		if len(enemies_in_area) == 1:
			target = get_next_enemy()

func _on_radius_area_exited(area):
	if area.is_in_group("enemies"):
		var parent = area.get_parent()
		enemies_in_area.erase(parent)
		target = get_next_enemy()

