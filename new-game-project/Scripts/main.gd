extends Node
const enemyPath = preload("res://Scenes/enemy.tscn")
@export var gun_type = "grape"
var enemy_name = ""
var occupied = [-1,-1,-1,-1]
var switching = false
signal start

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	$Player/HUD/Control/score.text = str(load.score)
	if load.playing and not load.sended:
		start.emit(gun_type)
		load.sended = true
		spawn_enemy()
		$Timer_difficulty_increase.start()
		$Timer_enemy_spawn.start()
		$Player/HUD/Control.set_visible(true)
		new_shop_location($shop1)
		new_shop_location($shop2)
		new_shop_location($shop3)
		new_shop_location($shop4)
	

func spawn_enemy():
	var rng = RandomNumberGenerator.new()
	var amount = rng.randi_range(load.min_amount_to_spawn,load.max_amount_to_spawn)
	
	#for every enemy we need to spawn
	for i in range(0, amount):
		var spawn_pos = random_spawn_pos()
		var random_type = rng.randi_range(1,10)
		if random_type <= 2:
			#1 in 5
			enemy_name = "speedy_bart"
		elif random_type <= 6:
			#3 in 10
			enemy_name = "medium_stef"
		elif random_type <= 9:
			#3 in 10
			enemy_name = "medium_ksander"
		elif random_type == 10:
			#1 in 10
			enemy_name = "big_dante"
		
		var enemy = enemyPath.instantiate()
		#this isnt really needed bc the player will never see the enemies spwan but just to be sure so one doesnt rack up a lot of velocity and shoots across the screen.
		var random_x = rng.randi_range(-10,10)
		var random_y = rng.randi_range(-10,10)
		enemy.position = spawn_pos + Vector2(random_x, random_y)
		enemy.enemy_name = enemy_name
		add_child(enemy)
	$Timer_enemy_spawn.start()

func random_spawn_pos() -> Vector2:
	#create new rng and get the players pos
	var rng = RandomNumberGenerator.new()
	#get all points
	var points = get_tree().get_nodes_in_group("SpawnPoints")
	var pointNr = rng.randi_range(0, len(points) - 1)
	var pointPos = points[pointNr].global_position
	
	var visonscreennode = points[pointNr].get_child(0)
	if not visonscreennode.is_on_screen():
		return pointPos #* 1.75
	else:
		return random_spawn_pos()

func increase_difficulty():
	load.difficulty += 1
	print("difficulty increased to " + str(load.difficulty))
	var time = $Timer_enemy_spawn.get_wait_time()
	if load.max_enemies_active <= 35:
		load.max_enemies_active += 1
	if load.max_amount_to_spawn <= 8:
		load.max_amount_to_spawn += 1
	if load.min_amount_to_spawn <= 4 and switching:
		load.min_amount_to_spawn += 1
	if load.enemySpeedMultipler <= 1.5:
		load.enemySpeedMultipler += 0.025
	if load.enemyHealthMultiplier <= 1.5:
		load.enemyHealthMultiplier += 0.025
	if time >= 1:
		$Timer_enemy_spawn.set_wait_time(time - 0.1)
	switching = not switching
func new_shop_location(shop):
	var rng = RandomNumberGenerator.new()
	var points = get_tree().get_nodes_in_group("shopSpawn")
	var pointNr = -1
	while true:
		pointNr = rng.randi_range(0, len(points) - 1)
		if not occupied.has(pointNr) and pointNr != shop.prev_loc:
			shop.prev_loc = pointNr
			var shopname = shop.get_name()
			occupied[shopname.to_int()-1] = pointNr
			var pointPos = points[pointNr].global_position
			shop.global_position = pointPos #*1.75
			break

func _on_timer_enemy_spawn_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies_node")
	if len(enemies) < load.max_enemies_active and load.playing:
		#print("spawned enemy " + str(len(enemies)))
		spawn_enemy()
		#print("timer ran out on " + str($Timer_enemy_spawn.get_wait_time()))

func _on_timer_difficulty_increase_timeout():
	if load.playing:
		increase_difficulty()

func startGame():
	var all_bullets = get_tree().get_nodes_in_group("bullet")
	for i in all_bullets:
		i.queue_free()
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for i in all_enemies:
		i.queue_free()
	var all_coins = get_tree().get_nodes_in_group("coin")
	for i in all_coins:
		i.queue_free()
	var all_hearts = get_tree().get_nodes_in_group("heart")
	for i in all_hearts:
		i.queue_free()
	$Player/main_menu/Control.set_visible(true)
	load.reset()
	occupied = [-1,-1,-1,-1]
	$dog.global_position = Vector2(-10000, -10000)
	$Timer_difficulty_increase.set_wait_time(30)
	$Timer_enemy_spawn.set_wait_time(3)
