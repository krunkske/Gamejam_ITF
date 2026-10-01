extends CanvasLayer

@onready var shop1 = get_tree().get_nodes_in_group("shops")[0]
@onready var shop2 = get_tree().get_nodes_in_group("shops")[1]
@onready var shop3 = get_tree().get_nodes_in_group("shops")[2]
@onready var shop4 = get_tree().get_nodes_in_group("shops")[3]
@onready var shopAnimNode1 = shop1.get_child(1)
@onready var shopShadeNode1 = shop1.get_child(2)
@onready var shopAnimNode2 = shop2.get_child(1)
@onready var shopShadeNode2 = shop2.get_child(2)
@onready var shopAnimNode3 = shop3.get_child(1)
@onready var shopShadeNode3 = shop3.get_child(2)
@onready var shopAnimNode4 = shop4.get_child(1)
@onready var shopShadeNode4 = shop4.get_child(2)

@onready var playerNode = load.player
@onready var hudMoneyNode = load.hud.get_child(0).get_child(5)

@onready var dash_cooldown_timer_node = playerNode.get_child(6)
@onready var dash_duration_timer_node = playerNode.get_child(7)

@export var shopnr = 0

@onready var default_dash_cooldwn_time = dash_cooldown_timer_node.get_wait_time()
@onready var default_dash_duration_time = dash_duration_timer_node.get_wait_time()

var items = [
	{"name": "speed", "price": 1000, "amount": 0, "max_amount": 3},
	{"name": "coin_range", "price": 1000, "amount":0, "max_amount": 3},
	{"name": "dash_cooldown", "price": 1500, "amount": 0, "max_amount": 3},
	{"name": "dash_duration", "price": 1500, "amount":0, "max_amount": 3},
	{"name": "max_health", "price": 2500, "amount": 0, "max_amount": 2},
	{"name": "damage", "price": 2500, "amount":0, "max_amount": 2},
	{"name": "resistance", "price": 3000, "amount":0, "max_amount": 2},
	{"name": "dog", "price": 3000, "amount":0, "max_amount": 1}
]

var bought_something = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/PanelContainer._set_size(get_viewport().get_visible_rect().size)

func _on_close_pressed():
	load.playing = true
	if items[7].amount == 1:
		load.dogActive = true
	$Control.set_visible(false)
	$Control/AudioStreamPlayer3.play()
	if shopnr == 1 and bought_something:
		shopAnimNode1.play("dissapear")
		shopShadeNode1.set_visible(false)
	elif shopnr == 2 and bought_something:
		shopAnimNode2.play("dissapear")
		shopShadeNode2.set_visible(false)
	elif shopnr == 3 and bought_something:
		shopAnimNode3.play("dissapear")
		shopShadeNode3.set_visible(false)
	elif shopnr == 4 and bought_something:
		shopAnimNode4.play("dissapear")
		shopShadeNode4.set_visible(false)
	bought_something = false

func player_can_buy(buff, price, node):
	if not price[1] >= price[2]:
		if load.money >= price[0]:
			load.money -= price[0]
			hudMoneyNode.text = str(load.money)
			node.set_text(buff + "\n" + str(price[3]) + " coins")
			#node.set_visible(false)
			$Control/AudioStreamPlayer2.play()
			return true
		else:
			$Control/AudioStreamPlayer.play()
			return false
	elif price[1] == price[2]:
		if load.money >= price[0]:
			load.money -= price[0]
			hudMoneyNode.text = str(load.money)
			node.set_text(buff + "\n" + "Sold Out")
			#node.set_visible(false)
			$Control/AudioStreamPlayer2.play()
			return true
		else:
			$Control/AudioStreamPlayer.play()
			return false
	else:
		$Control/AudioStreamPlayer.play()
		return false

func get_price(item):
	for i in items:
		if i.name == item:
			i.amount += 1
			var multiplier = 1
			var next_price_multiplier = 1
			if i.amount == 1:
				multiplier = 1
				next_price_multiplier = 1.5
			elif i.amount == 2:
				multiplier = 1.5
				next_price_multiplier = 2
			elif i.amount == 3:
				multiplier = 2
				next_price_multiplier = 2.5
			elif i.amount == 4:
				multiplier = 2.5
				next_price_multiplier = 2.5
			else:
				multiplier = 2
			
			if i.price * multiplier > load.money:
				i.amount -=1
				multiplier -= 0.5
				next_price_multiplier -= 0.5
			
			return [i.price * multiplier, i.amount, i.max_amount, i.price * next_price_multiplier]

func _on_speed_pressed():
	if player_can_buy("+30 Speed", get_price("speed"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/speed):
		playerNode.prev_speed += 30
		playerNode.speed = playerNode.prev_speed
		bought_something = true

func _on_dash_cooldown_pressed():
	if player_can_buy("-1 dash cooldown", get_price("dash_cooldown"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/dash_cooldown):
		var time = dash_cooldown_timer_node.get_wait_time()
		dash_cooldown_timer_node.set_wait_time(time - 1)
		bought_something = true

func _on_dash_duration_pressed():
	if player_can_buy("+0.1 dash duration", get_price("dash_duration"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/dash_duration):
		var time = dash_duration_timer_node.get_wait_time()
		dash_duration_timer_node.set_wait_time(time + 0.1)
		bought_something = true

func _on_max_health_pressed():
	if player_can_buy("+20 max health", get_price("max_health"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/max_health):
		load.max_health += 20
		load.health += 20
		playerNode.refresh_health()
		bought_something = true

func _on_coin_range_pressed():
	if player_can_buy("+30 coin magnet", get_price("coin_range"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/coin_range):
		load.radius += 30
		bought_something = true

func _on_damage_pressed():
	if player_can_buy("+20% damage", get_price("damage"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/damage):
		load.damageMultiplier += 0.2
		bought_something = true

func _on_resistance_pressed():
	if player_can_buy("+10% resistance", get_price("resistance"), $Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/resistance):
		load.resistance += 0.1
		bought_something = true

func resetShop():
	items = [
		{"name": "speed", "price": 1000, "amount": 0, "max_amount": 3},
		{"name": "coin_range", "price": 1000, "amount":0, "max_amount": 3},
		{"name": "dash_cooldown", "price": 1500, "amount": 0, "max_amount": 3},
		{"name": "dash_duration", "price": 1500, "amount":0, "max_amount": 3},
		{"name": "max_health", "price": 2500, "amount": 0, "max_amount": 2},
		{"name": "damage", "price": 2500, "amount":0, "max_amount": 2},
		{"name": "resistance", "price": 3000, "amount":0, "max_amount": 2},
	]
	bought_something = false
	
	dash_cooldown_timer_node.set_wait_time(default_dash_cooldwn_time)
	dash_duration_timer_node.set_wait_time(default_dash_duration_time)
	
	playerNode.speed = 200
	playerNode.prev_speed = 200
	
	#stupid but me dont care
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/speed.text = "+30 Speed\n1000 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/coin_range.text = "+30 coin magnet\n1000 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/dash_cooldown.text = "-1 dash cooldown\n1500 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/dash_duration.text = "+0.1 dash duration\n1500 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/max_health.text = "+20 max health\n2500 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/damage.text = "+20% damage\n2500 coins"
	$Control/PanelContainer/VBoxContainer/HBoxContainer/GridContainer/resistance.text = "+10% resistance\n3000 coins"
