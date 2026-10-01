extends CharacterBody2D

const bulletPath = preload("res://Scenes/bullet.tscn")
@onready var main = load.main
@onready var dogNode = load.dog
var gunData
var speed = 200
var prev_speed = 200
var knockback_force = 500
var knockback_direction = Vector2()
var knockback = Vector2()
var dash_force = Vector2()
@export var PlayerPos = Vector2.ZERO
var can_dash = true
var weapon_allowed_attack = true
var damaged = false
var knockback_active = false
var enemies_in_area = []
var touchscreen = false

func _ready():
	playerSpawn()
	if DisplayServer.is_touchscreen_available():
		touchscreen = true

	$HUD/Control/TextureProgressBar.value = load.health
	$HUD/Control.set_visible(false)

func _physics_process(delta):
	#INPUT
	velocity = Vector2.ZERO
	var currentAnim = "idle"
	if load.playing:
		if Input.is_action_pressed("up"):
			velocity.y -= 1
			currentAnim = "walkUp"
		if Input.is_action_pressed("down"):
			velocity.y += 1
			currentAnim = "walkDown"
		if Input.is_action_pressed("left"):
			velocity.x -= 1
			currentAnim = "walkSide"
			$AnimatedSprite2D.flip_h = true
		if Input.is_action_pressed("right"):
			velocity.x += 1
			currentAnim = "walkSide"
			$AnimatedSprite2D.flip_h = false
		
		if Input.is_action_pressed("shoot"):
			if weapon_allowed_attack:
				attack()
		
		if Input.is_action_pressed("dash"):
			if can_dash:
				dash()
		
		if Input.is_action_pressed("pause"):
			load.playing = false
			load.playing = false
			$pause/Control.set_visible(true)
	if not load.playing:
		$dash_cooldown_timer.set_paused(true)
	else:
		$dash_cooldown_timer.set_paused(false)
	
	$AnimatedSprite2D.play(currentAnim)
	
	
	if load.dashing:
		var dashDuration = $dash_duration_timer.get_time_left()
		$HUD/Control/dashBar.value = dashDuration * (100/$dash_duration_timer.get_wait_time())
	else:
		var dashTimeLeft = $dash_cooldown_timer.get_time_left()
		$HUD/Control/dashBar.value = 100 - dashTimeLeft * (100/$dash_cooldown_timer.get_wait_time())
	
	#knockback
	knockback_force -= 50
	if knockback_force <= 0:
		knockback_force = 0
		knockback_active = false
	knockback = knockback_direction * knockback_force
	
	#do some movement magic
	velocity = velocity.normalized() * speed + knockback
	move_and_slide()
	#gun look at mouse
	if touchscreen:
		$Node2D.rotation = load.joyDir.angle()
	else:
		var mousePos = get_global_mouse_position()
		$Node2D.look_at(mousePos)
		#store the layerPos for later (has to be exported)
	PlayerPos = position

func attack():
	#dependent on what weapon we chose TODO: change to if else statement instead of switch FIXED
	if load.playing:
		if gunData.texture == "grape":
			var angle = 0.5
			for i in range(-1, 4):
				var bullet = bulletPath.instantiate()
				bullet.transform = $Node2D/gun/Marker2D.global_transform
				bullet.rotation = $Node2D/gun/Marker2D.global_rotation + ((angle * i)/2)
				bullet.bullet_speed = gunData.bullet_speed
				bullet.texture = gunData.texture
				owner.add_child(bullet)
		else:
			var bullet = bulletPath.instantiate()
			bullet.transform = $Node2D/gun/Marker2D.global_transform
			bullet.bullet_speed = gunData.bullet_speed
			bullet.texture = gunData.texture
			owner.add_child(bullet)
		
		weapon_allowed_attack = false
		$attack_cooldown_timer.start()

func death():
	load.health = 0
	weapon_allowed_attack = false
	damaged = true
	load.playing = false
	load.dogActive = false
	$AnimatedSprite2D.play("death")
	$Node2D.hide()
	$HUD/Control/hp.text = str(load.health)
	$game_over.set_visible(true)
	$game_over.calculate_score()

func apply_knockback(force, enemy):
	if not knockback_active and load.playing:
		knockback_force = force
		knockback_direction = (global_position - enemy.global_position).normalized()
		knockback = knockback_direction.normalized() * knockback_force
		knockback_active = true

func choose_weapon(weapon):
	var json_as_text = FileAccess.get_file_as_string("res://Assets/json/guns.json")
	gunData = JSON.parse_string(json_as_text)
	
	gunData = gunData[weapon]
	
	$Node2D/gun/AnimatedSprite2D.play(weapon)
	$attack_cooldown_timer.wait_time = gunData.fire_rate
	$Node2D.set_visible(true)

func dash():
	can_dash = false
	load.dashing = true
	speed = 1200
	$HUD/Control/dash.text = "Dashing"
	$dash_duration_timer.start()
	$CPUParticles2D.restart()

func refresh_health():
	$HUD/Control/TextureProgressBar.set_max(load.max_health)
	$HUD/Control/TextureProgressBar.value = load.health
	$HUD/Control/hp.text = str(load.health)

func playerSpawn():
	var rng = RandomNumberGenerator.new()
	var points = get_tree().get_nodes_in_group("PlayerSpawn")

	if points.size() > 0:
		var pointNr = rng.randi_range(0, points.size() - 1)
		var pointPos = points[pointNr].global_transform.origin
		position = pointPos #* 1.75
	else:
		print("No spawn points found!")

func _on_area_2d_area_entered(area):
	#if area.is_in_group("enemies"):
		#apply_knockback(1250, area)
	if area.is_in_group("enemies") and not damaged and load.playing and not load.dashing:
		damaged = true
		load.health = load.health - (area.get_parent().damage - (area.get_parent().damage * load.resistance))
		$HUD/Control/TextureProgressBar.value = load.health
		$HUD/Control/hp.text = str(load.health)
		$damage_vunrabil_timer.start()
		if load.health <= 0 and load.playing:
			death()
		for i in 5:
			$AnimatedSprite2D.hide()
			await get_tree().create_timer(0.05).timeout
			$AnimatedSprite2D.show()
			await get_tree().create_timer(0.05).timeout
	elif area.is_in_group("heart") and load.health <= load.max_health:
		if load.health + 20 > load.max_health:
			load.health = load.max_health
		else:
			load.health = load.health + 20
		$HUD/Control/TextureProgressBar.value = load.health
		$HUD/Control/hp.text = str(load.health)
	elif area.is_in_group("coins"):
		load.money = load.money + area.value
		load.totalMoney = load.totalMoney + area.value
		$HUD/Control/money.text = str(load.money)

func _on_attack_cooldown_timer_timeout():
	weapon_allowed_attack = true

func _on_damage_vunrabil_timer_timeout():
	damaged = false

func _on_dash_duration_timer_timeout():
	speed = prev_speed
	load.dashing = false
	$dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout():
	can_dash = true

func _on_node_start(gun_type):
	load.playing = true
	weapon_allowed_attack = true
	choose_weapon(gun_type)
	refresh_health()
	speed = 200
	prev_speed = 200
	$HUD/Control/money.text = str(load.money)
