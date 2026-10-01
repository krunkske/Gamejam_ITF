extends Area2D

@onready var shopUINode =  load.shopUINode
@onready var shopUIControlNode = shopUINode.get_node("Control")
@onready var main = load.main
@export var prev_loc = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	shopUIControlNode.set_visible(false)
	$AnimatedSprite2D.play("idle")

func _on_area_entered(area):
	if area.is_in_group("player") and $AnimatedSprite2D.get_animation() != "dissapear":
		load.playing = false
		load.dogActive = false
		shopUIControlNode.show()
		shopUINode.shopnr = self.get_name().to_int()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.get_animation() == "dissapear":
		main.new_shop_location(self)
		$AnimatedSprite2D.play("idle")
		$LightOccluder2D.set_visible(true)
