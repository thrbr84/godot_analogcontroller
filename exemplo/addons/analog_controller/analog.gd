extends Node2D

enum typesAnalog { DIRECTION_2_H, DIRECTION_2_V, DIRECTION_4, DIRECTION_8, DIRECTION_360 }

onready var ball = Sprite.new()
onready var ballAnalogicoBall = Sprite.new()
onready var bg = Sprite.new()
onready var bgAnalogicoBase = Sprite.new()

const INACTIVE = -1

var initialized = false
var initial_position = Vector2.ZERO
var local_paused = false
var isDragging = false
var directions = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]
var parent
var listenerNode
var released = false
var currentForce2:float = 0.0
var centerPoint = Vector2(0,0)
var currentForce = Vector2(0,0)
var halfSize = Vector2()
var ballPos = Vector2()
var squaredHalfSizeLenght = 0
var currentPointerIDX = INACTIVE

export(bool) var isDynamicallyShowing = false
export(typesAnalog) var typeAnalogic = typesAnalog.DIRECTION_8
export(float,0.00,1.0) var smoothClick = 0.02
export(float,0.00,1.0) var smoothRelease = 0.02
export(Vector2) var scaleBall = Vector2(1,1)
export(Texture) var bigBallTexture = ResourceLoader.load("res://addons/analog_controller/big_circle_DIRECTION_8.png")
export(Texture) var smallBallTexture = ResourceLoader.load("res://addons/analog_controller/small_circle_DIRECTION_8.png")
export(Dictionary) var directionsResult = {
	"right":"right",
	"down_right":"down_right",
	"down":"down",
	"down_left":"down_left",
	"left":"left",
	"up_left":"up_left",
	"up":"up",
	"up_right":"up_right"
}

signal analogChange(force, pos)
signal analogPressed
signal analogRelease

func _ready() -> void:
	initial_position = global_position
	_configAnalog()
	initialized = true
	scale = Vector2(1,1)

func _configAnalog():
	set_process_input(true)
	
	if !initialized:
		add_child(bg)
		bg.add_child(bgAnalogicoBase)
		bg.scale = scaleBall
		bg.texture = bigBallTexture
		
		add_child(ball)
		ball.add_child(ballAnalogicoBall)
		ball.scale = scaleBall
		ball.texture = smallBallTexture
		
	parent = get_parent();
	
	halfSize = bg.texture.get_size()/2;
	squaredHalfSizeLenght = halfSize.x*halfSize.y;

	if isDynamicallyShowing:
		modulate.a = 0
	else:
		yield(get_tree().create_timer(.2), "timeout")
		position = initial_position
		modulate.a = 1
		show()

func _convertType(pos):
	if local_paused:return
	var angle = Vector2(pos.x, -pos.y).angle() + .5
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	var animation = directions[index-1]
	return animation

func get_force():
	if local_paused:return
	return currentForce
	
func _input(event):
	if local_paused:return
	
	var incomingPointer = extractPointerIdx(event)
	if incomingPointer == INACTIVE:
		return
	
	if need2ChangeActivePointer(event):
		if !isDragging: return
		if (currentPointerIDX != incomingPointer) and event.is_pressed():
			currentPointerIDX = incomingPointer;
			if event is InputEventMouseMotion or event is InputEventMouseButton:
				showAtPos(event.position)

	var theSamePointer = currentPointerIDX == incomingPointer
	if isActive() and theSamePointer:
		process_input(event)

func need2ChangeActivePointer(event):
	if local_paused:return
	var mouseButton = event is InputEventMouseButton
	var touch = event is InputEventScreenTouch
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var mouse_event_pos = event.position
		if mouseButton or touch:
			isDragging = true
			if isDynamicallyShowing:
				return mouse_event_pos
			else:
				var lenght = (get_global_position() - Vector2(mouse_event_pos.x, mouse_event_pos.y)).length_squared();
				return lenght < squaredHalfSizeLenght
		else:
		 return false
	else:
		return false

func isActive():
	if local_paused:return
	return currentPointerIDX != INACTIVE

func extractPointerIdx(event):
	if local_paused:return
	var touch = event is InputEventScreenTouch
	var drag = event is InputEventScreenDrag
	var mouseButton = event is InputEventMouseButton
	var mouseMove = event is InputEventMouseMotion
	
	if touch or drag:
		return event.index
	elif mouseButton or mouseMove:
		return 0
	else:
		return INACTIVE
		
func process_input(event):
	if local_paused:return
	var mouseButton = event is InputEventMouseButton
	var mouseMove = event is InputEventMouseMotion
	
	if mouseMove or mouseButton:
		calculateForce(event.position.x - self.get_global_position().x, event.position.y - self.get_global_position().y)
	updateBallPos()
	
	var isReleased = isReleased(event)
	if isReleased:
		reset()
	else:
		emit_signal("analogPressed")
		
		var _force = 0
		var _pos = Vector2.ZERO
		if typeAnalogic == typesAnalog.DIRECTION_360:
			_force = currentForce2
			_pos = currentForce.normalized() * Vector2(1, -1)
			
			emit_signal("analogChange", _force, _pos)
			return
			
		elif typeAnalogic == typesAnalog.DIRECTION_2_H:

			_force = currentForce2
			var converted = _convertType(currentForce)
			_pos = directionsResult[converted]
			
			match _pos:
				"right": 		_force = Vector2(1, 0) * _force
				"left": 		_force = Vector2(-1, 0) * _force
					
				_: 	_force = Vector2.ZERO
			
			if _force is Vector2:
				_force = _force.normalized()
				
			emit_signal("analogChange", _force * currentForce2, _pos)
			
		elif typeAnalogic == typesAnalog.DIRECTION_2_V:

			_force = currentForce2
			var converted = _convertType(currentForce)
			_pos = directionsResult[converted]
			
			match _pos:
				"up": 			_force = Vector2(0, -1) * _force
				"down": 		_force = Vector2(0, 1) * _force
				_: 				_force = Vector2.ZERO
			
			if _force is Vector2:
				_force = _force.normalized()
				
			emit_signal("analogChange", _force * currentForce2, _pos)

			
		elif typeAnalogic == typesAnalog.DIRECTION_4:

			_force = currentForce2
			var converted = _convertType(currentForce)
			_pos = directionsResult[converted]
			
			match _pos:
				"right": 		_force = Vector2(1, 0) * _force
				"left": 		_force = Vector2(-1, 0) * _force
				"up": 			_force = Vector2(0, -1) * _force
				"down": 		_force = Vector2(0, 1) * _force
				_: 				_force = Vector2.ZERO
			
			if _force is Vector2:
				_force = _force.normalized()
				
			emit_signal("analogChange", _force * currentForce2, _pos)

				
		elif typeAnalogic == typesAnalog.DIRECTION_8:
			
			_force = currentForce2
			var converted = _convertType(currentForce)
			_pos = directionsResult[converted]
			
			match _pos:
				"right": 		_force = Vector2(1, 0) * _force
				"down_right": 	_force = Vector2(1, 1) * _force
				"up_right": 	_force = Vector2(1, -1) * _force
				"left": 		_force = Vector2(-1, 0) * _force
				"down_left": 	_force = Vector2(-1, 1) * _force
				"up_left": 		_force = Vector2(-1, -1) * _force
				"up": 			_force = Vector2(0, -1) * _force
				"down": 		_force = Vector2(0, 1) * _force
				_: 				_force = Vector2.ZERO
				
			if _force is Vector2:
				_force = _force.normalized()
				
			emit_signal("analogChange", _force * currentForce2, _pos)

func reset() -> void:
	emit_signal("analogRelease")
	currentPointerIDX = INACTIVE
	calculateForce(0, 0)

	if isDynamicallyShowing:
		hide()
	else:
		updateBallPos()

func showAtPos(pos) -> void:
	if local_paused: return
	if !isDynamicallyShowing: return

	self.set_global_position(pos)
	while self.modulate.a < 1.0 and isActive():
		yield(get_tree().create_timer(smoothClick), "timeout")
		self.modulate.a += .1
	
	if !isActive():
		self.modulate.a = 0
			
func hide() -> void:
	while self.modulate.a > 0.0 and !isActive():
		yield(get_tree().create_timer(smoothRelease), "timeout")
		self.modulate.a -= .1
	
	emit_signal("analogRelease")

func updateBallPos() -> void:
	if local_paused:return
	
	if typeAnalogic != typesAnalog.DIRECTION_2_V:
		ballPos.x = halfSize.x * currentForce.x
	
	if typeAnalogic != typesAnalog.DIRECTION_2_H:
		ballPos.y = halfSize.y * -currentForce.y
		
	ballPos *= scaleBall 
	ball.set_position(ballPos)
	
	var bigBallSize = (bg.texture.get_size().x / 2) * scaleBall.x
	currentForce2 = (centerPoint.distance_to(ballPos) * 100.0 / bigBallSize) / 100.0
	currentForce2 = stepify(currentForce2, .001)
	currentForce2 = clamp(currentForce2, -1.0, 1.0)


func calculateForce(var x, var y) -> void:
	if local_paused:return
	if typeAnalogic != typesAnalog.DIRECTION_2_V:
		currentForce.x = (x - centerPoint.x)/halfSize.x
	
	if typeAnalogic != typesAnalog.DIRECTION_2_H:
		currentForce.y = -(y - centerPoint.y)/halfSize.y
	
	if currentForce.length_squared()>1:
		currentForce=currentForce/currentForce.length()
	
func isPressed(event):
	if local_paused:return
	if event is InputEventMouseMotion:
		return (event.button_mask==1)
	elif event is InputEventScreenTouch:
		isDragging = true
		return event.pressed

func isReleased(event):
	if event is InputEventScreenTouch:
		return !event.pressed
	elif event is InputEventMouseButton:
		return !event.pressed

func pause() -> void:
	local_paused = true
	hide()
	
func unpause() -> void:
	local_paused = false
