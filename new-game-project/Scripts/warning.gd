extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	if load.get_value("seen_dialouge_box") != null:
		if DisplayServer.is_touchscreen_available():
			print("phone")
			self.set_visible(true)
		else:
			print("no phone")
			self.set_visible(false)
	else:
		print("no phone")
		self.set_visible(false)

func _on_button_pressed():
	load.config.set_value("user", "seen_dialouge_box", true)
	self.set_visible(false)
