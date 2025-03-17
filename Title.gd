extends Node2D

func _ready():
	$HBoxContainer/TextureButton.modulate.a = 0.5
	
	$HBoxContainer/TextureButton2.modulate.a = 0.5


func _on_TextureButton_pressed():
	Game.get_node("Game").load_player("Warrior")
	Game.get_node("Game").start_game()
	queue_free()


func _on_TextureButton2_pressed():
	Game.get_node("Game").load_player("Swordmaster")
	Game.get_node("Game").start_game()
	queue_free()


func _on_TextureButton_mouse_entered():
	$HBoxContainer/TextureButton.modulate.a = 1
	$Descriptor.text = "Koomarian Warrior"


func _on_TextureButton_mouse_exited():
	$HBoxContainer/TextureButton.modulate.a = 0.5
	$Descriptor.text = ""


func _on_TextureButton2_mouse_entered():
	
	$HBoxContainer/TextureButton2.modulate.a = 1
	$Descriptor.text = "Boomarian Swordmaster"

func _on_TextureButton2_mouse_exited():

	$HBoxContainer/TextureButton2.modulate.a = 0.5
	$Descriptor.text = ""
