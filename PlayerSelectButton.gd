extends TextureButton

func _ready():
	modulate.a = 0.5  # Set opacity to 50% initially

func _on_mouse_entered():
	modulate.a = 1.0  # Set opacity to 100% when hovered

func _on_mouse_exited():
	modulate.a = 0.5  # Set opacity back to 50% when not hovered
