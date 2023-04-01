extends Node2D

@onready var AnalogController = $CanvasLayerUI/AnalogController
@onready var players = $players
@onready var plane_shoot = $players/plane/shoot
@onready var spark_anim = $players/spark/anim

var bullet = preload("res://scenes/bullet.tscn")
var speed = 10
var velocity = Vector2.ZERO
var player = null
var sparkPathAnim = "res://assets/persons/spark/[ACTION]/[DIR].png"
var planePathAnim = "res://assets/plane1.png"

var colorOff = Color(.55, .28, .06, 1)
var colorOn = Color(.17, .70, .02, 1)
var direction = "down"
var cacheTexture = {}

func _on_AnalogController_analogChange(force, pos):
	if pos is String:
		velocity = (force) * (2 * player.scale)
		_movement_human(force, pos)
		
	else:
		velocity = (pos * force) * speed

func _on_AnalogController_analogRelease():
	velocity = Vector2.ZERO
	_load_player_texture("idle", direction)

"""
BASIC EXAMPLE -------------------------
"""

func _ready():
	_pre_cache()
	var idx = 0
	for options in get_tree().get_nodes_in_group("btn"):
		var tsb: TouchScreenButton = options.get_node("action")
		tsb.pressed.connect(_on_player_select.bind(options.name))
	
		if idx == 0:
			_on_player_select(options.name)
			pass
		idx += 1
	
	
	
func _physics_process(_delta):
	if weakref(player).get_ref():
		player.position += velocity

func _shoot():
	if weakref(player).get_ref():
		if player.is_in_group("plane"):
			var b = bullet.instantiate()
			b.global_position = plane_shoot.global_position
			get_tree().get_root().call_deferred("add_child", b)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_shoot()
		
	if event is InputEventScreenTouch:
		if event.index == 1:
			_shoot()

func _on_player_select(player_option):
	player = null
	
	for options in get_tree().get_nodes_in_group("btn"):
		options.get_node("bkg").color = colorOff
		if options.name == str(player_option):
			options.get_node("bkg").color = colorOn
	
	for players in get_tree().get_nodes_in_group("player"):
		players.hide()
	
	if players.has_node(str(player_option)):
		player = players.get_node(str(player_option))
		player.show()
		
		if player.is_in_group("human"):
			AnalogController.typeAnalogic = AnalogController.typesAnalog.DIRECTION_8
			_load_player_texture("idle", direction)
		else:
			AnalogController.typeAnalogic = AnalogController.typesAnalog.DIRECTION_360
			
func _load_player_texture(_action = "idle", _dir = "down"):
	if player.is_in_group("human"):
		var key = str(_action, "_", _dir)
		
		if player.get_node("anim").current_animation != str(_action):
			player.get_node("anim").play(str(_action))
			
		if player.texture != cacheTexture[key]:
			player.texture = cacheTexture[key]
	else:
		player.texture = load(planePathAnim)

func _pre_cache():
	for ac in ['idle', 'walk']:
		for dr in ['right', 'down_right', 'up_right', 'left', 'down_left', 'up_left', 'up', 'down']:
			var texturePath = sparkPathAnim
			texturePath = texturePath.replace("[ACTION]", ac)
			texturePath = texturePath.replace("[DIR]", dr)
			
			var key = str(ac, "_", dr)
			if !cacheTexture.has(key):
				cacheTexture[key] = load(texturePath)

func _movement_human(force, pos):
	direction = pos
	_load_player_texture("walk", direction)
	
	if player.is_in_group("human"):
		var speedWalk = 5.0 * force.length()
		spark_anim.speed_scale = speedWalk 

func _on_dynamicController_toggled(button_pressed):
	AnalogController.isDynamicallyShowing = button_pressed
	AnalogController._configAnalog()
