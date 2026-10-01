extends Node

var config = ConfigFile.new()


@onready var main = get_tree().root.get_child(1)
@onready var player = get_tree().root.get_child(1).get_child(1)
@onready var dog = get_tree().root.get_child(1).get_child(9)
@onready var highscoresNode = get_tree().root.get_child(1).get_child(1).get_child(3)
@onready var publishNode = get_tree().root.get_child(1).get_child(1).get_child(18).get_child(0)
@onready var creditsNode = get_tree().root.get_child(1).get_child(1).get_child(19)
@onready var shopUINode =  get_tree().root.get_child(1).get_child(1).get_child(4)
@onready var mainMenuNode = get_tree().root.get_child(1).get_child(1).get_child(1)
@onready var mainMenuControlNode = get_tree().root.get_child(1).get_child(1).get_child(1).get_child(0)
@onready var gameOverControlNode = get_tree().root.get_child(1).get_child(1).get_child(2).get_child(0)
@onready var hud = get_tree().root.get_child(1).get_child(1).get_child(5)
@onready var skinsNode = get_tree().root.get_child(1).get_child(1).get_child(20)
#general
var money = 0
var totalMoney = 0
var score = 0
var playing = false
var joyDir = Vector2.ZERO
var sended = false
var min_amount_to_spawn = 1
var max_amount_to_spawn = 2
var max_enemies_active = 6
var difficulty = 0
var noScore = false
var came_from_where = 0

#player
var health = 100
var max_health = 100
var resistance = 0
var dashing = false

#coin
var radius = 20

#dog
var dogActive = false
var latestDead = Node
var dogSkin = "bart"
var dogSkinPreload = null

#enemy
var damageMultiplier = 1
var enemySpeedMultipler = 1
var enemyHealthMultiplier = 1

func get_value(value):
	var err = config.load_encrypted_pass("user://save.cfg", "aVerySafePasswordImadeIn15seconds!")
	if err == OK:
		return config.get_value("user", value)
	else:
		return null

func save_save():
	config.save_encrypted_pass("user://save.cfg", "aVerySafePasswordImadeIn15seconds!")

func reset():
	sended = false
	health = 100
	max_health = 100
	money = 0
	totalMoney = 0
	score = 0
	resistance = 0
	radius = 20
	min_amount_to_spawn = 1
	max_amount_to_spawn = 2
	max_enemies_active = 6
	enemySpeedMultipler = 1
	enemyHealthMultiplier = 1
	difficulty = 0
	dogActive = false
	latestDead = Node
	noScore = false
	
	damageMultiplier = 1
	player.playerSpawn()
	shopUINode.resetShop()
