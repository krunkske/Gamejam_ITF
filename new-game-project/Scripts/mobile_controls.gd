extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	$Control/TouchScreenButton.position = Vector2($Control/PanelContainer.get_size().x/2-42, $Control/PanelContainer.get_size().y - $Control/PanelContainer.get_size().y/3)
	$"Control/Virtual Joystick".position = Vector2($Control/PanelContainer.get_size().x/5, $Control/PanelContainer.get_size().y - $Control/PanelContainer.get_size().y/4)
	$"Control/Virtual Joystick2".position = Vector2($Control/PanelContainer.get_size().x/1.5, $Control/PanelContainer.get_size().y - $Control/PanelContainer.get_size().y/4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vector = Vector2.ZERO
	move_vector.x = Input.get_axis("l", "r")
	move_vector.y = Input.get_axis("u", "d")
	load.joyDir = move_vector

