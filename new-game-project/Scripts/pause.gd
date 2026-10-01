extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control.set_visible(false)

func _on_button_pressed():
	load.playing = true
	$Control.set_visible(false)
