extends KinematicBody

var velocity: Vector3 = Vector3.ZERO
var speed = 5
var gravity := Vector3.DOWN * 10
var jump_force := 5
var mouse_rotation := 0.05
var is_jumping := false
var is_analog_pressed := false
var analog_velocity = Vector2.ZERO
var target_turn = 0

onready var analog_controller = get_parent().get_node("HUD/AnalogController")
onready var tleft_controller = get_parent().get_node("HUD/Turn_Left")
onready var tright_controller = get_parent().get_node("HUD/Turn_Right")
onready var jump_controller = get_parent().get_node("HUD/Turn_Jump")
onready var pc_info = get_parent().get_node("HUD/bkg/ComputerInfo")

func _ready():
	if OS.get_name() == "Android":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_display_hud_controllers(true)
		pc_info.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_display_hud_controllers(false)

func _display_hud_controllers(state):
	if state:
		analog_controller.unpause()
		analog_controller.show()
		tleft_controller.show()
		tright_controller.show()
		jump_controller.show()
	else:
		analog_controller.pause()
		tleft_controller.hide()
		tright_controller.hide()
		jump_controller.hide()
	
func _physics_process(delta):
	velocity += gravity * delta
	get_input(delta)
	get_analog_movement(delta)
	
	if tleft_controller.is_visible_in_tree():
		rotate_y(lerp(0, -mouse_rotation * target_turn * speed, 0.1))
	
	if (is_jumping == true or Input.is_action_just_pressed("jump")) and is_on_floor():
		is_jumping = true
		velocity.y = velocity.normalized().y + jump_force
	else:
		is_jumping = false
	
	var snap_vector = Vector3.DOWN if not is_jumping else Vector3.ZERO
	
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, deg2rad(70))

func get_input(delta):
	if is_analog_pressed: return
	if tleft_controller.is_visible_in_tree(): return
	var input = Vector3.ZERO
	
	if Input.is_action_pressed("w"):
		input += -transform.basis.z * speed
	if Input.is_action_pressed("s"):
		input += +transform.basis.z * speed
	if Input.is_action_pressed("a"):
		input += -transform.basis.x * speed
	if Input.is_action_pressed("d"):
		input += +transform.basis.x * speed
	
	velocity.x = input.x
	velocity.z = input.z

func _unhandled_input(event):
	if is_analog_pressed: return
	if event is InputEventMouseMotion:
		if !tleft_controller.is_visible_in_tree():
			rotate_y(-lerp(0, mouse_rotation, event.relative.x / 10))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_display_hud_controllers(true)
		
	if Input.is_action_just_pressed("ui_accept") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_display_hud_controllers(false)

func _on_AnalogController_analogChange(force, pos:Vector2):
	analog_velocity = (pos * force).normalized()

func get_analog_movement(delta):
	if !is_analog_pressed: return
	var input = Vector3.ZERO
	input += -transform.basis.x * analog_velocity.x
	input += -transform.basis.z * analog_velocity.y
	velocity.x = -input.x * speed
	velocity.z = -input.z * speed

func _on_AnalogController_analogPressed():
	is_analog_pressed = true

func _on_AnalogController_analogRelease():
	is_analog_pressed = false
	velocity = Vector3.ZERO

func _on_Turn_Left_pressed():
	target_turn = -1

func _on_Tur_Right_pressed():
	target_turn = 1
	
func _on_Turn_released():
	target_turn = 0

func _on_Turn_Jump_pressed():
	is_jumping = true
