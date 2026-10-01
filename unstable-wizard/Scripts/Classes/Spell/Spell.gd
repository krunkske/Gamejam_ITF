extends Node2D

enum SpellType {
	FIREBALL,
	LIGHTNING,
	WIND
}

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		cast_random_spell()


func cast_random_spell():
	var spell = randi_range(0, 2)

	match spell:
		SpellType.FIREBALL:
			fireball()
		SpellType.LIGHTNING:
			lightning()
		SpellType.WIND:
			wind()


func fireball():
	var projectile = preload("res://spells/fireball.tscn").instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position
	projectile.direction = global_position.direction_to(get_global_mouse_position())


func lightning():
		var target_position = get_global_mouse_position()

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < 100:
			enemy.take_damage(50)



func wind():
	var target_position = get_global_mouse_position()

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if enemy.global_position.distance_to(target_position) < 250:
			var direction = enemy.global_position.direction_to(target_position)

			enemy.velocity += direction * 500
