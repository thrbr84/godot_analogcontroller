extends Node2D

onready var AnalogController = $CanvasLayerUI/AnalogController

var bullet = preload("res://scenes/bullet.tscn")
var speed = 1
var velocity = Vector2.ZERO
onready var player = $players/plane
var planePathAnim = "res://assets/plane1.png"
var controllers = {}
var key_maps = {
	"left": KEY_A,
	"right": KEY_D,
	"up": KEY_W,
	"down": KEY_S
}

func _on_AnalogController_analogChange(force, pos):
	#velocity = (pos * force) * speed
	
	var dir = AnalogController._convertType(Vector2(pos.x, -pos.y))
	
	# Simulating by action like "ui_left", "ui_right", etc.
	# simulate_action(dir)
	
	# Simulating by key pressed like KEY_A, KEY_W, etc.
	simulate_key(dir)

func _on_AnalogController_analogRelease():
	velocity = Vector2.ZERO
	reset_controls()

func reset_controls():
	stop_simulate_action("up")
	stop_simulate_action("down")
	stop_simulate_action("left")
	stop_simulate_action("right")
	
	stop_simulate_key("up")
	stop_simulate_key("down")
	stop_simulate_key("left")
	stop_simulate_key("right")

"""
BASIC EXAMPLE -------------------------
"""

func _ready():
	AnalogController.typeAnalogic = AnalogController.typesAnalog.DIRECTION_360

func _physics_process(_delta):
	if weakref(player).get_ref():
		player.position += velocity
		
	get_input()

func _shoot():
	if weakref(player).get_ref():
		if player.is_in_group("plane"):
			var b = bullet.instance()
			b.global_position = $players/plane/shoot.global_position
			get_tree().get_root().call_deferred("add_child", b)

func get_input():
	if Input.is_action_just_pressed("ui_accept"):
		_shoot()
	
	var l_pressed = Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)
	var r_pressed = Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)
	var u_pressed = Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W)
	var d_pressed = Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S)

	velocity = Vector2.ZERO
	if l_pressed or r_pressed or u_pressed or d_pressed:
		velocity.x = (int(r_pressed) - int(l_pressed)) * speed
		velocity.y = (int(d_pressed) - int(u_pressed)) * speed

func _input(event):
	if event is InputEventScreenTouch:
		if event.index == 1:
			_shoot()

func _load_player_texture():
	player.texture = load(planePathAnim)

func _on_dynamicController_toggled(button_pressed):
	AnalogController.isDynamicallyShowing = button_pressed
	AnalogController._configAnalog()

func simulate_action(which_action):
	reset_controls()

	var s = which_action.split("_")
	for x in s:
		var waction = str("ui_", x)
		
		#if !controllers.has(waction):
		#	controllers[waction] = null
		
		#if controllers[waction] == null:
		#	controllers[waction] = 1
		var ev = InputEventAction.new()
		ev.pressed = true
		ev.action = waction
		Input.parse_input_event(ev)

func stop_simulate_action(which_action):
	var s = which_action.split("_")
	for x in s:
		var waction = str("ui_", x)
		
		#if !controllers.has(waction):
		#	controllers[waction] = null
		
		#if controllers[waction] != null:
		#	controllers[waction] = null
		var ev = InputEventAction.new()
		ev.pressed = false
		ev.action = waction
		Input.parse_input_event(ev)

func simulate_key(which_key_mapped):
	
	var s = which_key_mapped.split("_")
	for waction in s:
		if key_maps.has(waction):
			var which_key = key_maps[waction]
			var ev = InputEventKey.new()
			ev.scancode = which_key
			ev.pressed = true
			Input.parse_input_event(ev)
			#get_tree().input_event(ev)
	
func stop_simulate_key(which_key_mapped):
	var s = which_key_mapped.split("_")
	for waction in s:
		if key_maps.has(waction):
			var which_key = key_maps[waction]
			var ev = InputEventKey.new()
			ev.scancode = which_key
			ev.pressed = true
			#get_tree().input_event(ev)
			Input.parse_input_event(ev)
