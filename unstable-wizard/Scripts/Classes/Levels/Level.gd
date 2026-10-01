extends Node2D

const enemyPath = preload("res://Scenes/Enemy/Enemy.tscn")

func _ready() -> void:
	for child in get_children():
		if child is TileMapLayer:
			_add_wall_collisions(child)

func _add_wall_collisions(tile_layer: TileMapLayer) -> void:
	for cell in tile_layer.get_used_cells():
		var source_id = tile_layer.get_cell_source_id(cell)
		var atlas_source = tile_layer.tile_set.get_source(source_id)
		if not atlas_source is TileSetAtlasSource:
			continue
		if not atlas_source.texture.resource_path.ends_with("/TX Tileset Wall.png"):
			continue

		var body := StaticBody2D.new()
		body.position = tile_layer.map_to_local(cell)
		body.collision_layer = 1
		body.collision_mask = 0
		tile_layer.add_child(body)

		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(tile_layer.tile_set.tile_size)
		collision.shape = shape
		body.add_child(collision)

func _on_spawn_enemy_timeout() -> void:
	spawn_enemy()

func spawn_enemy():
	var rng = RandomNumberGenerator.new()
	var amount = rng.randi_range(1, 3)
	
	#for every enemy we need to spawn
	for i in range(0, amount):
		var enemy_name = ""
		var random_type = rng.randi_range(1, 3)
		if random_type == 1:
			enemy_name = "goblin"
		elif random_type == 2:
			#3 in 10
			enemy_name = "golem"
		elif random_type == 3:
			#3 in 10
			enemy_name = "knight"
		var spawn_pos = random_spawn_pos()
		if enemy_name == "goblin":
			spawn_pos = random_goblin_spawn_pos()
		
		var enemy = enemyPath.instantiate()
		#this isnt really needed bc the player will never see the enemies spwan but just to be sure so one doesnt rack up a lot of velocity and shoots across the screen.
		var random_x = rng.randi_range(-10,10)
		var random_y = rng.randi_range(-10,10)
		enemy.position = spawn_pos + Vector2(random_x, random_y)
		enemy.enemy_name = enemy_name
		print("spawned enemy at" + str(enemy.position))
		add_child(enemy)
	increase_difficulty()
	
	$spawnEnemy.start()

func random_goblin_spawn_pos() -> Vector2:
	var points = get_tree().get_nodes_in_group("goblin_spawnpoints")
	if points.is_empty():
		return random_spawn_pos()

	var point = points[randi_range(0, points.size() - 1)]
	return point.global_position + Vector2(randf_range(-80.0, 80.0), randf_range(-80.0, 80.0))

func random_spawn_pos() -> Vector2:
	#create new rng and get the players pos
	var rng = RandomNumberGenerator.new()
	#get all points
	var points = get_tree().get_nodes_in_group("spawnpoints")
	var pointNr = rng.randi_range(0, len(points) - 1)
	var pointPos = points[pointNr].global_position
	
	var visonscreennode = points[pointNr].get_child(0)
	if not visonscreennode.is_on_screen():
		return pointPos #* 1.75
	else:
		return random_spawn_pos()


func increase_difficulty():
	var time = $spawnEnemy.wait_time
	if time >= 1:
		$spawnEnemy.set_wait_time(time - 0.01)
