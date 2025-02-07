extends Control

func initialise(domino):
	$Popup/Node2D.set_domino(domino)
	$Popup/Node2D.active = false
	$Popup.rect_position = Vector2(960-200, 0)
	$Popup.popup()

