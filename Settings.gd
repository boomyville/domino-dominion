extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if(Engine.time_scale == 1.0):
		_on_Button_pressed()
	elif(Engine.time_scale == 3.0):
		_on_Button2_pressed()
	elif(Engine.time_scale == 10.0):
		_on_Button3_pressed()
	else:
		_on_Button_pressed()

	if Game.get_node("Game").touch_mode:
		$GridContainer/Container2/CheckButton.pressed = true
	if Game.get_node("Game").detailed_descriptors:
		$GridContainer/Container3/CheckButton.pressed = true

func _on_Button_pressed():
	$GridContainer/Container/Button2.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button3.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button.modulate = Color(1, 1, 1, 1)
	
	Engine.time_scale = 1.0
	Engine.iterations_per_second = 60  # Smoother physics updates


func _on_Button2_pressed():
	$GridContainer/Container/Button.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button3.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button2.modulate = Color(1, 1, 1, 1)
	
	Engine.time_scale = 3.0
	Engine.iterations_per_second = 180  # Smoother physics updates

func _on_Button3_pressed():
	$GridContainer/Container/Button2.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button.modulate = Color(1, 1, 1, 0.5)
	$GridContainer/Container/Button3.modulate = Color(1, 1, 1, 1)
	
	Engine.time_scale = 10.0
	Engine.iterations_per_second = 600  # Smoother physics updates

func _on_exit_button_pressed():
	queue_free()


func _on_CheckButton2_pressed():
	Game.get_node("Game").detailed_descriptors = $GridContainer/Container3/CheckButton.pressed


func _on_CheckButton_pressed():
	Game.get_node("Game").touch_mode = $GridContainer/Container2/CheckButton.pressed
