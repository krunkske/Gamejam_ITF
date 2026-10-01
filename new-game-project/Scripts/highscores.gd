extends CanvasLayer

@onready var mainMenuControlNode = load.mainMenuControlNode
@onready var gameOverControlNode = load.gameOverControlNode
var get_scores = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Control.set_visible(false)
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	$Control/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ItemList.clear()
	for i in json:
		$Control/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/ItemList.add_item(str(i.position) + ": " + str(i.nickname) + ": " + str(i.score) ,null, false)
	if json == null:
		$Control/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/scoresLabel.text = str(response_code);
		# "An error occured. THe web server may be down or inacessible."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_scores:
		get_scores = false
		var error = $HTTPRequest.request("https://zombiechaos.be/api/highscores.php")
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func _on_button_pressed():
	$Control.set_visible(false)
	if load.health == 0:
		gameOverControlNode.set_visible(true)
	else:
		mainMenuControlNode.set_visible(true)
	$Control/AudioStreamPlayer.play()
