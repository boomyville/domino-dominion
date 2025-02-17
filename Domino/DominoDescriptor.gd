extends Control

func initialise(domino):
	$Popup/Node2D.set_domino(domino)
	$Popup/Node2D.active = false
	$Popup.rect_position = Vector2(960-200, 0)
	$Popup.popup()

func upgrade_domino_initialise(domino, upgrade_level: int = 1, over_upgrade: bool = false):
	$Popup/Node2D.set_domino(domino, upgrade_level, over_upgrade)
	$Popup/Node2D.active = false
	$Popup.rect_position = Vector2(0, 0)
	$Popup.popup()
