tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AnalogController", "Node2D", preload("res://addons/analog_controller/analog.gd"), preload("res://addons/analog_controller/icon.png"))

func _exit_tree():
	remove_custom_type("AnalogController")
