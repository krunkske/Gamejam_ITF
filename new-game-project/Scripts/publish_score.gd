extends CanvasLayer

var token = ""
@onready var game_over_control_node = load.gameOverControlNode

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	$Control.set_visible(false)

func _on_button_pressed():
	if not load.noScore:
		$Control/PanelContainer/VBoxContainer/Label.text = ""
		var superSecretKey = "bQpUX2V8EUntCIWcG7FIGTY9l8PDjXlt"
		var validate = str(superSecretKey, load.score, token.to_upper()).sha256_text()
		var url = "https://zombiechaos.be/api/addscore.php?score=" + str(load.score) + "&token=" + str(token) + "&validation=" + validate
		$HTTPRequest.request(url)
	else:
		$Control/PanelContainer/VBoxContainer/Label.text = "You can not upload higscores in cheat mode."

func _on_http_request_request_completed(result, response_code, headers, body):
	var answer = body[2]-48

	if answer == 0:
		$Control/PanelContainer/VBoxContainer/Label.text = "Sucessvol gepubliceerd!"
	elif answer == 1:
		$Control/PanelContainer/VBoxContainer/Label.text = "Ongeldige Token. Probeer opnieuw."
	elif answer == 2:
		$Control/PanelContainer/VBoxContainer/Label.text = "Score is lager dan huidige highscore."
	elif answer == 3:
		$Control/PanelContainer/VBoxContainer/Label.text = "Validatie ongeldig. Probeer opnieuw."
	elif answer == 4:
		$Control/PanelContainer/VBoxContainer/Label.text = "Probleem met verbinding highscore server."
	elif answer == 5:
		$Control/PanelContainer/VBoxContainer/Label.text = "Token is al eerder gebruikt. Gebruik een andere token."

func _on_line_edit_text_changed(new_text):
	token = new_text

func _on_button_2_pressed():
	if load.came_from_where == 1:
		load.mainMenuControlNode.set_visible(true)
		load.score = 0
	else:
		game_over_control_node.set_visible(true)
	$Control.set_visible(false)
	$Control/PanelContainer/VBoxContainer/Label.text = ""
