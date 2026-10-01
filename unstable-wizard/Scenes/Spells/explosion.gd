extends AnimatedSprite2D

const SPRITE_SHEET = preload("res://Scenes/Spells/Explosion_2_SpriteSheet.png")
const FRAME_SIZE := 48
const FRAME_COUNT := 18

func _ready() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("explosion")
	frames.set_animation_speed("explosion", 24.0)
	frames.set_animation_loop("explosion", false)
	for frame_index in FRAME_COUNT:
		var frame := AtlasTexture.new()
		frame.atlas = SPRITE_SHEET
		frame.region = Rect2(frame_index * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
		frames.add_frame("explosion", frame)

	sprite_frames = frames
	animation = "explosion"
	scale = Vector2.ONE * 3
	animation_finished.connect(queue_free)
	play()
