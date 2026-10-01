extends CanvasLayer

@onready var main_menu_control_node = load.mainMenuControlNode

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	self.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_pressed():
	self.set_visible(false)
	main_menu_control_node.set_visible(true)
	
