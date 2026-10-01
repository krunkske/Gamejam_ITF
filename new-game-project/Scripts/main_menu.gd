extends CanvasLayer

@onready var main = load.main
@onready var highscoresNode = load.highscoresNode
@onready var highscoresControlNode = get_tree().root.get_child(1).get_child(1).get_child(3).get_child(1)
@onready var creditsNode = load.creditsNode
@onready var playerNode = load.player
var gun_int = 0

var sequence = ["up", "up", "down", "down", "left", "right", "left", "right"]

var sequence_index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	highscoresControlNode.set_visible(false)
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	
	if OS.has_feature("nameweb_android") or OS.has_feature("web_ios"):
		pass
	var index = load.get_value("fruit")
	if index == null:
		index = 0
	$Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButton._select_int(index)
	if index == 0:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 40"
	elif index == 1:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 25"
	elif index == 2:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 15 \n Pellets: 6"
	get_local_highscore()
	
	#wont work due to retry
	#if load.get_value("local_highscore") == null:
		#$Control/PanelContainer/VBoxContainer/publish_local_highscore.set_visible(false)

func _on_button_pressed():
	$Control.set_visible(false)
	gun_int = $Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButton.selected
	if gun_int == 0:
		main.gun_type = "banana"
	elif gun_int == 1:
		main.gun_type = "apple"
	elif gun_int == 2:
		main.gun_type = "grape"
	load.playing = true
	$Control/AudioStreamPlayer.play()

func _on_scores_pressed():
	highscoresControlNode.set_visible(true)
	$Control.set_visible(false)
	highscoresNode.get_scores = true
	$Control/AudioStreamPlayer.play()

func _on_credits_pressed():
	$Control/AudioStreamPlayer.play()
	creditsNode.set_visible(true)
	$Control.set_visible(false)

func _on_option_button_item_selected(index):
	if index == 0:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 40"
	elif index == 1:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 25"
	elif index == 2:
		$Control/PanelContainer/VBoxContainer/HBoxContainer/Stats.text = "Damage: 15 \n Pellets: 6"
	load.config.set_value("user", "fruit", index)
	load.save_save()

func _on_performance_item_selected(index):
	if index == 0:
		print("previous:" + str(get_viewport().size))
		set_resolution(1)
		print("current:" + str(get_viewport().size))
	elif index == 1:
		print("previous:" + str(get_viewport().size))
		set_resolution(0.75)
		print("current:" + str(get_viewport().size))
	elif index == 2:
		print("previous:" + str(get_viewport().size))
		set_resolution(0.5)
		print("current:" + str(get_viewport().size))

func set_resolution(scale_factor):
	# Get the root Viewport

	# Set the resolution based on the scale factor
	var original_size = get_viewport().get_visible_rect().size
	var new_size = original_size * scale_factor
	get_viewport().size = new_size

func get_local_highscore():
	if load.get_value("local_highscore") != null:
		$Control/PanelContainer/VBoxContainer/HBoxContainer6/local_highscore.text = "local highscore: " + str(load.get_value("local_highscore"))
	if load.get_value("level") != null:
		$Control/PanelContainer/VBoxContainer/HBoxContainer9/level.text = "level " + str(load.get_value("level"))
	if load.get_value("level_progress") != null:
		$Control/PanelContainer/VBoxContainer/HBoxContainer9/levelBar.value = load.get_value("level_progress")

func _on_skins_pressed():
	$Control.set_visible(false)
	load.skinsNode.set_visible(true)


func _on_left_pressed():
	if sequence[sequence_index] == "left":
		sequence_index += 1
	else:
		sequence_index = 0
	
	print(sequence_index)
	
	if sequence_index == len(sequence):
		konami_code()


func _on_up_pressed():
	if sequence[sequence_index] == "up":
		sequence_index += 1
	else:
		sequence_index = 0
	
	print(sequence_index)
	
	if sequence_index == len(sequence):
		konami_code()


func _on_down_pressed():
	if sequence[sequence_index] == "down":
		sequence_index += 1
	else:
		sequence_index = 0
	
	print(sequence_index)
	
	if sequence_index == len(sequence):
		konami_code()


func _on_right_pressed():
	if sequence[sequence_index] == "right":
		sequence_index += 1
	else:
		sequence_index = 0
	
	print(sequence_index)
	
	if sequence_index == len(sequence):
		konami_code()

func konami_code():
	sequence_index = 0
	load.money += 1000000
	load.noScore = true

func _on_publish_local_highscore_pressed():
	$Control.set_visible(false)
	load.came_from_where = 1
	load.score = load.get_value("local_highscore")
	load.publishNode.get_child(0).get_child(0).get_child(0).text = "score: " + str(load.score)
	load.publishNode.set_visible(true)
