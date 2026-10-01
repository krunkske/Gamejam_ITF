extends CanvasLayer

const bart = preload("res://Assets/dog/1 Dog/dog1.tres")
const jef = preload("res://Assets/dog/2 Dog/dog2.tres")
const kitty = preload("res://Assets/dog/1 cat/cat1.tres")
const missy = preload("res://Assets/dog/2 cat/cat2.tres")
const oliver = preload("res://Assets/dog/1 rat/rat1.tres")
const luna = preload("res://Assets/dog/2 rat/rat2.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)
	self.set_visible(false)
	load.dogSkinPreload = bart
	change_anim("dog", "bart")

func _on_back_pressed():
	self.set_visible(false)
	load.mainMenuControlNode.set_visible(true)

func _on_bart_pressed():
	if can_select(1):
		load.dogSkinPreload = bart
		change_anim("dog", "bart")

func _on_jef_pressed():
	if can_select(5):
		load.dogSkinPreload = jef
		change_anim("dog", "jef")

func _on_kitty_pressed():
	if can_select(10):
		load.dogSkinPreload = kitty
		change_anim("dog", "kitty")

func _on_missy_pressed():
	if can_select(15):
		load.dogSkinPreload = missy
		change_anim("dog", "missy")

func _on_oliver_pressed():
	if can_select(20):
		load.dogSkinPreload = oliver
		change_anim("dog", "oliver")

func _on_luna_pressed():
	if can_select(30):
		load.dogSkinPreload = luna
		change_anim("dog", "luna")

func change_anim(type, naam):
	if type == "dog":
		load.dogSkin = naam
		$Control/PanelContainer/ScrollContainer/VBoxContainer/dogSelected.text = str(load.dogSkin) + " selected"
		load.dog.get_child(0).set_sprite_frames(load.dogSkinPreload)
		load.dog.get_child(0).play("walk")

func can_select(level_req):
	var level = load.get_value("level")
	if level == null:
		level = 1
	if level >= level_req:
		$Control/AudioStreamPlayer2.play()
		return true
	else:
		$Control/AudioStreamPlayer.play()
		return false
