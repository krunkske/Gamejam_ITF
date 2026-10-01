extends Node2D

@onready var player: CharacterBody2D = $player
@onready var menu: Control = $MenuLayer/Menu
@onready var start_button: TextureButton = $MenuLayer/Menu/StartButton
@onready var start_button_material: ShaderMaterial = start_button.material as ShaderMaterial

var start_button_tween: Tween
var start_button_pulse: Tween
var start_button_hover_tween: Tween


func _ready() -> void:
	player.hide()
	get_tree().paused = true
	start_button.pressed.connect(_start_game)
	start_button.mouse_entered.connect(_on_start_button_mouse_entered)
	start_button.mouse_exited.connect(_on_start_button_mouse_exited)
	start_button.grab_focus()
	start_button.pivot_offset = start_button.size / 2.0
	var resting_y := start_button.position.y
	start_button_tween = create_tween().set_loops()
	start_button_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	start_button_tween.tween_property(start_button, "position:y", resting_y - 8.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	start_button_tween.tween_property(start_button, "position:y", resting_y, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	start_button_pulse = create_tween().set_loops()
	start_button_pulse.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	start_button_pulse.tween_property(start_button, "scale", Vector2(1.012, 1.012), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	start_button_pulse.tween_property(start_button, "scale", Vector2.ONE, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _start_game() -> void:
	start_button_tween.kill()
	start_button_pulse.kill()
	if start_button_hover_tween and start_button_hover_tween.is_running():
		start_button_hover_tween.kill()
	menu.hide()
	player.show()
	get_tree().paused = false


func _on_start_button_mouse_entered() -> void:
	_animate_start_button_glow(1.0)


func _on_start_button_mouse_exited() -> void:
	_animate_start_button_glow(0.0)


func _animate_start_button_glow(target_strength: float) -> void:
	if start_button_hover_tween and start_button_hover_tween.is_running():
		start_button_hover_tween.kill()
	start_button_hover_tween = create_tween()
	start_button_hover_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	start_button_hover_tween.tween_property(start_button_material, "shader_parameter/glow_strength", target_strength, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
