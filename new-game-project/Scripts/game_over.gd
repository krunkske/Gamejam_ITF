extends CanvasLayer

@onready var scoresNode = load.highscoresNode
@onready var scoresControlNode = scoresNode.get_child(1)
@onready var main = load.main
@onready var main_menu = load.mainMenuNode

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	self.set_visible(false)
	$Control/TextureProgressBar.position = Vector2($Control/PanelContainer.get_size().x/2-105, $Control/PanelContainer.get_size().y - $Control/PanelContainer.get_size().y/2.75)

func calculate_score():
	if not load.noScore:
		
		var local_highscore = load.get_value("local_highscore")
		var level = load.get_value("level")
		var level_progress = load.get_value("level_progress")
		
		if local_highscore == null or local_highscore < load.score:
			load.config.set_value("user", "local_highscore", load.score)
		
		if level == null:
			level = 1
		if level_progress == null:
			level_progress = 0
		
		$Control/PanelContainer/VBoxContainer/level.text = "level: " + str(level)
		$Control/PanelContainer/VBoxContainer/HBoxContainer/totalMoney.text = "total money: " + str(load.totalMoney)
		$Control/PanelContainer/VBoxContainer/HBoxContainer/score.text = "score: " + str(load.score)
		
		var levelProgressionMultiplier = 1 + (0.05*level)
		var actual_score = (load.score + load.totalMoney)/2
		var actual_score_percentage = (float(actual_score)/(10000*levelProgressionMultiplier)*100)
		
		level_progress += actual_score_percentage
		
		await get_tree().create_timer(1).timeout
		
		for i in range(level_progress):
			var amount = 1
			$Control/TextureProgressBar.value += 1
			$Control/PanelContainer/VBoxContainer/HBoxContainer/totalMoney.text = "total money: " + str(int(load.totalMoney - (load.totalMoney*((i+1)/float(level_progress)))))
			$Control/PanelContainer/VBoxContainer/HBoxContainer/score.text = "score: " + str(int(load.score - (load.score*((i+1)/float(level_progress)))))
			if $Control/TextureProgressBar.value == 100:
				$Control/TextureProgressBar.value = 0
				$Control/PanelContainer/VBoxContainer/level.text = "level: " + str(level + (1*amount))
				amount += 1
			await get_tree().create_timer(0.01).timeout
		
		while level_progress >= 100:
			level += 1
			level_progress -= 100
		
		$Control/PanelContainer/VBoxContainer/level.text = "level: " + str(level)
		$Control/PanelContainer/VBoxContainer/HBoxContainer/totalMoney.text = "total money: 0"
		$Control/PanelContainer/VBoxContainer/HBoxContainer/score.text = "score: 0"
		
		load.config.set_value("user", "level", level)
		load.config.set_value("user", "level_progress", level_progress)
		
		print(level)
		print(level_progress)
		
		load.save_save()

func restart_game():
	self.set_visible(false)
	main.startGame()

func _on_retry_pressed():
	$Control/AudioStreamPlayer.play()
	main_menu.get_local_highscore()
	restart_game()

func _on_scores_pressed():
	scoresNode.get_child(1).set_visible(true)
	scoresNode.get_scores = true
	$Control.set_visible(false)
	$Control/AudioStreamPlayer.play()

func _on_publish_score_pressed():
	$Control/AudioStreamPlayer.play()
	$Control.set_visible(false)
