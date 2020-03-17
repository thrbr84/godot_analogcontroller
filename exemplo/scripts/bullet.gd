extends Node2D

func _physics_process(_delta):
	global_position.y -= 50

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
